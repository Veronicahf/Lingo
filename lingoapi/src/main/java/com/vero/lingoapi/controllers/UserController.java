package com.vero.lingoapi.controllers;

import com.vero.lingoapi.models.dtos.UserProfileDTO;
import com.vero.lingoapi.services.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador REST para la gestión de perfiles de usuario.
 * <p>
 * Expone endpoints protegidos que requieren autenticación.
 * Recibe el UID desde la ruta, delega la lógica en {@link UserService}
 * y retorna un {@link ResponseEntity} con el resultado.
 * </p>
 *
 * <h2>Flujo de consulta de perfil (GET /users/{uid}/profile)</h2>
 * <ol>
 *   <li>El frontend envía una petición GET con el UID en la ruta.</li>
 *   <li>Spring extrae el UID mediante {@link PathVariable}.</li>
 *   <li>Se pasa el UID a {@link UserService#getProfile(String)}.</li>
 *   <li>Si el usuario existe, retorna 200 OK con {@link UserProfileDTO}.</li>
 *   <li>Si no existe, el servicio lanza {@link java.util.NoSuchElementException}
 *       y {@link GlobalExceptionHandler} lo traduce a 404 Not Found.</li>
 * </ol>
 */
@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Obtiene el perfil completo de un usuario por su UID de Firebase.
     *
     * @param uid Identificador único de Firebase (extraído de la ruta)
     * @return 200 OK con los datos del perfil, o 404 si no existe
     */
    @GetMapping("/{uid}/profile")
    public ResponseEntity<UserProfileDTO> getProfile(@PathVariable String uid) {
        UserProfileDTO profile = userService.getProfile(uid);
        return ResponseEntity.ok(profile);
    }
}
