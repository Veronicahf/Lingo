package com.vero.lingoapi.models.dtos;

/**
 * DTO que transporta los datos necesarios para registrar un nuevo usuario.
 * <p>
 * Flujo de datos:
 * <ol>
 *   <li>El frontend envía un JSON con uid, email, name, avatarUrl y courseId
 *       en el cuerpo de la petición POST /auth/register.</li>
 *   <li>Spring deserializa el JSON en una instancia de {@code UserRegisterDTO}
 *       gracias a {@link org.springframework.web.bind.annotation.RequestBody}.</li>
 *   <li>El {@code AuthController} recibe el DTO y lo pasa directamente
 *       al {@code UserService}.</li>
 *   <li>El {@code UserService} extrae los datos, construye una entidad
 *       {@link com.vero.lingoapi.models.entities.AppUser} con valores
 *       por defecto (500 gemas, 5 corazones, etc.) y la persiste.</li>
 *   <li>Además, crea el registro de progreso inicial en
 *       {@code user_course_progress} vinculando al usuario con el curso
 *       seleccionado durante el onboarding.</li>
 *   <li>El resultado se devuelve como {@link UserProfileDTO} hacia el frontend.</li>
 * </ol>
 * </p>
 *
 * @param uid       Identificador único de Firebase Auth (PK del usuario)
 * @param email     Correo electrónico del usuario
 * @param name      Nombre visible del usuario en la plataforma
 * @param avatarUrl URL pública del avatar del usuario (opcional)
 * @param courseId  Identificador del curso seleccionado en onboarding
 *                  (ej. "course_en"). Si es nulo, se asume "course_en".</p>
 */
public record UserRegisterDTO(
        String uid,
        String email,
        String name,
        String avatarUrl,
        String courseId
) {
}
