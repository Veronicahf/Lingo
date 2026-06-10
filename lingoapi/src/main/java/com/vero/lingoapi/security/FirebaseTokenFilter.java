package com.vero.lingoapi.security;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Instant;
import java.util.Collections;
import java.util.List;

/**
 * Filtro de seguridad que valida tokens de Firebase Auth en cada petición.
 * <p>
 * Extiende {@link OncePerRequestFilter} garantizando que cada petición
 * sea procesada una sola vez dentro del ciclo de vida del filtro, incluso
 * si hay redirecciones internas o forwards entre servlets.
 * </p>
 *
 * <h2>Ciclo de vida del filtro en la petición</h2>
 * <ol>
 *   <li>El contenedor de Servlets recibe la petición HTTP.</li>
 *   <li>La cadena de filtros de Spring Security se ejecuta en orden.
 *       {@link FirebaseTokenFilter} está registrado antes que
 *       {@code UsernamePasswordAuthenticationFilter} (ver {@link SecurityConfig}).</li>
 *   <li>El filtro verifica si la ruta solicitada está en la lista de rutas públicas.
 *       Si lo está, salta la validación y continúa la cadena.</li>
 *   <li>Para rutas protegidas, extrae el header {@code Authorization}
 *       y verifica que tenga el formato {@code Bearer <token>}.</li>
 *   <li>Si el token no está presente, retorna 401 (no se continúa la cadena).</li>
 *   <li>Si el token está presente, lo envía a Firebase Admin SDK
 *       ({@link FirebaseAuth#verifyIdToken(String)}) para su validación criptográfica.</li>
 *   <li>Si Firebase rechaza el token (expirado, malformado, revocado),
 *       retorna 401 y no continúa la cadena.</li>
 *   <li>Si el token es válido, extrae el {@code uid} y lo coloca en el
 *       {@link SecurityContextHolder} como un {@link UsernamePasswordAuthenticationToken}.
 *       Luego continúa la cadena con la autenticación establecida.</li>
 *   <li>Los controladores pueden acceder al UID mediante
 *       {@link SecurityContextHolder#getContext().getAuthentication().getPrincipal()}.</li>
 * </ol>
 */
@Component
public class FirebaseTokenFilter extends OncePerRequestFilter {

    /**
     * Rutas públicas que no requieren autenticación.
     * Solo el onboarding es público porque el frontend lo muestra
     * antes de que el usuario se registre/login.
     * {@code /auth/register} y {@code /auth/login} ahora requieren
     * token porque Firebase es la única fuente de verdad para la identidad.
     */
    private static final List<String> PUBLIC_PATHS = List.of(
            "/onboarding/questions"
    );

    public FirebaseTokenFilter() {
    }

    /**
     * Determina si el filtro debe omitirse para la petición actual.
     * <p>
     * Si la ruta solicitada coincide con alguna ruta pública,
     * el filtro no ejecuta ninguna validación y pasa la petición
     * directamente al siguiente eslabón de la cadena.
     * </p>
     *
     * @param request Petición HTTP entrante
     * @return {@code true} si la ruta es pública (omitir filtro)
     */
    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        String contextPath = request.getContextPath();
        if (contextPath != null && !contextPath.isEmpty()) {
            path = path.substring(contextPath.length());
        }
        return PUBLIC_PATHS.stream().anyMatch(path::startsWith);
    }

    /**
     * Procesa cada petición HTTP entrante.
     * <p>
     * <b>Flujo de validación:</b>
     * <ol>
     *   <li>Extrae el header {@code Authorization}.</li>
     *   <li>Si no existe o no comienza con {@code "Bearer "}, escribe
     *       un JSON de error 401 y detiene la cadena.</li>
     *   <li>Extrae el token (substring después de {@code "Bearer "}).</li>
     *   <li>Verifica el token con {@link FirebaseAuth#verifyIdToken(String)}.</li>
     *   <li>Si la verificación falla (excepción de Firebase), escribe
     *       un JSON de error 401 y detiene la cadena.</li>
     *   <li>Si el token es válido, crea un {@link UsernamePasswordAuthenticationToken}
     *       con el UID como principal y lo establece en el contexto de seguridad.</li>
     *   <li>Continúa la cadena de filtros.</li>
     * </ol>
     * </p>
     *
     * @param request     Petición HTTP entrante
     * @param response    Respuesta HTTP
     * @param filterChain Cadena de filtros a ejecutar después
     */
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            writeUnauthorizedResponse(response, "Token de autenticación no proporcionado");
            return;
        }

        String token = authHeader.substring(7);

        try {
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(token);
            String uid = decodedToken.getUid();

            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(uid, decodedToken, Collections.emptyList());

            SecurityContextHolder.getContext().setAuthentication(authentication);

            filterChain.doFilter(request, response);

        } catch (Exception e) {
            writeUnauthorizedResponse(response, "Token inválido o expirado: " + e.getMessage());
        }
    }

    /**
     * Escribe una respuesta JSON estructurada con código 401 Unauthorized.
     * <p>
     * Limpia el contexto de seguridad y escribe en el cuerpo de la respuesta
     * un objeto JSON con el formato: {@code {"error": "...", "timestamp": "...", "status": 401}}.
     * </p>
     *
     * @param response Respuesta HTTP donde se escribirá el error
     * @param message  Mensaje descriptivo del error
     * @throws IOException Si hay error al escribir en el flujo de salida
     */
    private void writeUnauthorizedResponse(HttpServletResponse response, String message) throws IOException {
        SecurityContextHolder.clearContext();
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");

        String json = String.format(
                "{\"error\":\"%s\",\"status\":%d,\"timestamp\":\"%s\"}",
                message, HttpStatus.UNAUTHORIZED.value(), Instant.now()
        );

        response.getWriter().write(json);
    }
}
