package com.vero.lingoapi.models.dtos;

/**
 * DTO que representa el perfil completo de un usuario.
 * <p>
 * Se utiliza tanto en la respuesta de registro (201 Created) como en
 * la consulta de perfil (GET /users/{uid}/profile). Contiene todos
 * los campos visibles de la entidad {@link com.vero.lingoapi.models.entities.AppUser},
 * incluyendo los de gamificación (streakDays, gems, totalXp, hearts).
 * </p>
 *
 * @param uid             Identificador único de Firebase Auth
 * @param email           Correo electrónico del usuario
 * @param name            Nombre visible en la plataforma
 * @param avatarUrl       URL del avatar (puede ser vacío)
 * @param streakDays      Días consecutivos de actividad (racha)
 * @param gems            Gemas disponibles (moneda virtual)
 * @param totalXp         Puntos de experiencia totales
 * @param hearts          Corazones restantes (vidas para lecciones)
 * @param currentCourseId ID del curso actualmente seleccionado
 * @param createdAt       Fecha de creación en formato ISO-8601
 */
public record UserProfileDTO(
        String uid,
        String email,
        String name,
        String avatarUrl,
        int streakDays,
        int gems,
        int totalXp,
        int hearts,
        String currentCourseId,
        String createdAt
) {
}
