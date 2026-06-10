package com.vero.lingoapi.models.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Entidad que representa un curso de idiomas disponible en Lingo.
 * <p>
 * Cada fila de esta tabla equivale a un idioma que el usuario puede
 * aprender (ej. Inglés, Francés, Italiano). Los datos del curso son
 * independientes de cualquier usuario, lo que evita la redundancia
 * y las anomalías de actualización que ocurrirían si el nombre del
 * curso estuviera embebido en la tabla {@link AppUser}.
 * </p>
 *
 * <h2>Cumplimiento de la Segunda Forma Normal (2FN)</h2>
 * <p>
 * Antes de esta separación, la información del curso (nombre,
 * descripción, código de idioma) podría haber estado duplicada
 * en cada registro de {@code app_user} donde un usuario tuviera
 * seleccionado ese curso. Esto violaba la 2FN porque:
 * <ul>
 *   <li>Los atributos del curso dependían del ID del curso, no
 *       directamente del UID del usuario (dependencia transitiva).</li>
 *   <li>Actualizar el nombre de "Inglés" a "Inglés Americano"
 *       requería modificar TODAS las filas de usuario que tuvieran
 *       ese curso (anomalía de actualización).</li>
 *   <li>Eliminar el último usuario de un curso perdía la información
 *       del curso (anomalía de borrado).</li>
 *   <li>No se podía tener un curso sin al menos un usuario asignado
 *       (anomalía de inserción).</li>
 * </ul>
 * </p>
 * <p>
 * Al normalizar en una tabla separada {@code Course}:
 * <ul>
 *   <li>El nombre del curso existe una sola vez y se referencia
 *       por FK desde {@code app_user.current_course_id}.</li>
 *   <li>Actualizar el nombre del curso se hace en UNA fila.</li>
 *   <li>Se pueden crear cursos sin usuarios asignados.</li>
 *   <li>La tabla {@code app_user} solo almacena estadísticas del
 *       estudiante, cumpliendo con la 1FN y 2FN.</li>
 * </ul>
 * </p>
 *
 * @see AppUser
 */
@Entity
@Table(name = "courses")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Course {

    /**
     * Identificador único del curso.
     * Es un VARCHAR semántico que sigue el patrón {@code course_<código>},
     * ej: {@code course_en} para Inglés, {@code course_es} para Español.
     * Al ser una clave natural legible, simplifica las referencias
     * desde el frontend y las consultas en base de datos.
     */
    @Id
    @Column(name = "id", length = 32, nullable = false)
    private String id;

    /** Nombre del curso en español (ej. "Inglés", "Francés"). */
    @Column(name = "name", length = 128, nullable = false)
    private String name;

    /**
     * Descripción corta del curso (ej. "Aprende inglés desde cero
     * con lecciones interactivas").
     */
    @Column(name = "description", length = 512)
    private String description;

    /**
     * Código ISO 639-1 del idioma que se enseña (ej. "en", "fr", "it").
     * Útil para integraciones con APIs de traducción o para mostrar
     * banderas en el frontend.
     */
    @Column(name = "language_code", length = 8, nullable = false)
    private String languageCode;

    /** Fecha y hora de creación del registro (autogenerada). */
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /** Fecha y hora de la última modificación (autogenerada). */
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
