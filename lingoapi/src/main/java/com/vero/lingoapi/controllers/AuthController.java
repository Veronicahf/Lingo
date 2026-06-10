package com.vero.lingoapi.controllers;

import com.google.firebase.auth.FirebaseToken;
import com.vero.lingoapi.models.dtos.UserProfileDTO;
import com.vero.lingoapi.models.dtos.UserRegisterDTO;
import com.vero.lingoapi.services.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador REST para autenticación.
 * <p>
 * Ahora la identidad del usuario se extrae <b>exclusivamente del JWT
 * de Firebase</b> que viaja en el header {@code Authorization}. El
 * frontend nunca envía el UID, email o nombre en el body; Firebase
 * es la única fuente de verdad.
 * </p>
 *
 * <h2>Flujo del registro (POST /auth/register)</h2>
 * <ol>
 *   <li>El {@link com.vero.lingoapi.security.FirebaseTokenFilter} valida
 *       el JWT y lo coloca en el {@link SecurityContextHolder}.</li>
 *   <li>El controlador extrae {@code uid}, {@code email}, {@code name}
 *       y {@code picture} del {@link FirebaseToken} verificado.</li>
 *   <li>El body HTTP es opcional y solo aporta el {@code courseId}.</li>
 *   <li>Se llama a {@link UserService#register(String, String, String, String, String)}.</li>
 *   <li>Si el UID ya existe → 409 Conflict (para que el frontend ejecute upsert).</li>
 *   <li>Si es nuevo → 201 Created con el perfil.</li>
 * </ol>
 *
 * <h2>Flujo del login (POST /auth/login)</h2>
 * <ol>
 *   <li>El filtro valida el JWT y establece la autenticación.</li>
 *   <li>El controlador extrae solo el {@code uid} del contexto.</li>
 *   <li>Se llama a {@link UserService#login(String)}.</li>
 *   <li>Si existe → 200 OK con el {@link UserProfileDTO} directamente.</li>
 *   <li>Si no existe → 404 (el frontend interpreta que debe registrar).</li>
 * </ol>
 */
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Registra un nuevo usuario extrayendo la identidad del JWT de Firebase.
     * <p>
     * El body es opcional y solo contiene el {@code courseId} seleccionado
     * en onboarding. Todos los datos personales (uid, email, name, picture)
     * provienen del token verificado por el filtro de seguridad.
     * </p>
     *
     * @param dto DTO opcional con el courseId (los datos sensibles vienen del token)
     * @return 201 Created con el perfil, o 409 Conflict si ya existe
     */
    @PostMapping("/register")
    public ResponseEntity<UserProfileDTO> register(
            @RequestBody(required = false) UserRegisterDTO dto) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String uid = (String) auth.getPrincipal();
        FirebaseToken token = (FirebaseToken) auth.getCredentials();

        String email = token.getEmail();
        String name = token.getName() != null ? token.getName() : "Estudiante";
        String picture = token.getPicture();
        String courseId = dto != null ? dto.courseId() : null;

        UserProfileDTO profile = userService.register(uid, email, name, picture, courseId);
        return ResponseEntity.status(HttpStatus.CREATED).body(profile);
    }

    /**
     * Verifica la existencia del usuario extrayendo el UID del token.
     * <p>
     * No recibe body. El UID viene del JWT verificado por el filtro.
     * Retorna el perfil directamente (sin wrapper {@code exists}),
     * permitiendo que Flutter lo mapee con {@code .fromJson()} directo.
     * </p>
     *
     * @return 200 OK con el perfil si existe, 404 si no está registrado
     */
    @PostMapping("/login")
    public ResponseEntity<UserProfileDTO> login() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String uid = (String) auth.getPrincipal();

        UserProfileDTO profile = userService.login(uid);

        if (profile == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        return ResponseEntity.ok(profile);
    }
}
