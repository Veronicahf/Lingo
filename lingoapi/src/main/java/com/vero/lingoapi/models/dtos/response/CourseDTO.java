package com.vero.lingoapi.models.dtos.response;

/**
 * DTO que representa un curso de idiomas disponible en la plataforma.
 * <p>
 * Corresponde al catálogo que el frontend muestra en la pantalla de
 * selección de idioma. Cada {@code CourseDTO} se renderiza como una
 * tarjeta con ícono de bandera, nombre del idioma y descripción.
 * </p>
 *
 * @param id           Identificador único del curso (ej. "course_en")
 * @param name         Nombre del idioma en español (ej. "Inglés")
 * @param description  Descripción corta del curso
 * @param languageCode Código ISO 639-1 (ej. "en", "fr")
 */
public record CourseDTO(
        String id,
        String name,
        String description,
        String languageCode
) {
}
