package com.vero.lingoapi.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

/**
 * Configuración principal de seguridad de la API Lingo.
 * <p>
 * Define cómo se comporta Spring Security frente a cada petición HTTP:
 * política de sesiones, reglas de autorización por ruta, CORS, CSRF,
 * y el registro del filtro {@link FirebaseTokenFilter}.
 * </p>
 *
 * <h2>Interacción del filtro con el ciclo de vida de la petición</h2>
 * <p>
 * La cadena de seguridad de Spring Security se ejecuta antes de que
 * la petición llegue a los controladores. El orden es:
 * <ol>
 *   <li><b>Filtros de CORS</b> — agregan headers de acceso
 *       ({@code Access-Control-Allow-Origin}, etc.) a la respuesta.</li>
 *   <li><b>Filtro CSRF</b> — está deshabilitado ({@code csrf.disable()})
 *       porque nuestra API usa tokens Bearer, no cookies de sesión.</li>
 *   <li><b>{@link FirebaseTokenFilter}</b> — se ejecuta <i>antes</i> del
 *       {@link UsernamePasswordAuthenticationFilter} (el filtro estándar
 *       de formulario login de Spring). Extrae y valida el token JWT
 *       de Firebase, estableciendo el {@code SecurityContext} si es válido.</li>
 *   <li><b>{@link UsernamePasswordAuthenticationFilter}</b> — se salta
 *       porque no existe un formulario de login (sesión stateless).</li>
 *   <li><b>{@code FilterSecurityInterceptor}</b> — verifica las reglas
 *       declaradas en {@code authorizeHttpRequests()} y decide si
 *       permite o deniega el acceso al controlador.</li>
 * </ol>
 * </p>
 *
 * <p>
 * El filtro {@link FirebaseTokenFilter} se encarga de la validación del token
 * (autenticación), mientras que esta configuración determina qué rutas
 * requieren autenticación (autorización). Ambos trabajan en conjunto:
 * si el filtro no establece el {@code SecurityContext}, el interceptor
 * denegará el acceso con 403 para las rutas que requieren autenticación.
 * </p>
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final FirebaseTokenFilter firebaseTokenFilter;

    public SecurityConfig(FirebaseTokenFilter firebaseTokenFilter) {
        this.firebaseTokenFilter = firebaseTokenFilter;
    }

    /**
     * Construye la cadena principal de filtros de seguridad.
     * <p>
     * <b>Configuraciones aplicadas:</b>
     * <ul>
     *   <li><b>CSRF deshabilitado:</b> no necesitamos protección contra
     *       falsificación de solicitudes entre sitios porque la API no
     *       utiliza cookies de sesión, sino tokens Bearer estateless.</li>
     *   <li><b>Política de sesión STATELESS:</b> Spring Security no creará
     *       ni usará sesiones HTTP. Cada petición contiene toda la información
     *       de autenticación en el token Bearer.</li>
     *   <li><b>Autorización por ruta:</b>
     *     <ul>
     *       <li>{@code GET /onboarding/**} — público (preguntas estáticas).</li>
     *       <li>{@code OPTIONS /**} — público (preflight CORS, nunca debe
     *           dar 403 para que el navegador complete el handshake).</li>
     *       <li>{@code POST /auth/**} — requiere autenticación con token
     *           Firebase (la identidad se extrae del JWT, no del body).</li>
     *       <li>{@code GET /users/**} — requiere autenticación (token válido).</li>
     *       <li>Cualquier otro request — requiere autenticación.</li>
     *     </ul>
     *   </li>
     *   <li><b>CORS:</b> configuración detallada en {@link #corsConfigurationSource()}.</li>
     *   <li><b>Filtro de Firebase:</b> registrado antes de
     *       {@link UsernamePasswordAuthenticationFilter}.</li>
     * </ul>
     * </p>
     *
     * @param http Builder de seguridad HTTP de Spring
     * @return {@link SecurityFilterChain} completamente configurada
     * @throws Exception Si hay error en la configuración
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(HttpMethod.GET, "/onboarding/**").permitAll()
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/auth/**").authenticated()
                .requestMatchers(HttpMethod.GET, "/users/**").authenticated()
                .anyRequest().authenticated()
            )
            .addFilterBefore(firebaseTokenFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * Configuración de CORS (Cross-Origin Resource Sharing).
     * <p>
     * Permite que aplicaciones Flutter Web (ejecutándose en un navegador
     * con origen diferente) y Flutter Mobile puedan consumir la API sin
     * ser bloqueadas por la política de mismo origen del navegador.
     * </p>
     * <p>
     * <b>Configuración:</b>
     * <ul>
     *   <li><b>allowedOrigins:</b> {@code *} — en desarrollo permite cualquier
     *       origen. En producción debe restringirse al dominio del frontend.</li>
     *   <li><b>allowedMethods:</b> GET, POST, PUT, DELETE, PATCH, OPTIONS
     *       — los métodos HTTP estándar para una API REST.</li>
     *   <li><b>allowedHeaders:</b> {@code *} — permite cualquier header,
     *       incluyendo {@code Authorization} para el token Bearer.</li>
     *   <li><b>allowCredentials:</b> {@code true} — permite el envío de
     *       credenciales (cookies, headers de autorización).</li>
     * </ul>
     * </p>
     *
     * @return Fuente de configuración CORS basada en patrones de URL
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(List.of("*"));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
