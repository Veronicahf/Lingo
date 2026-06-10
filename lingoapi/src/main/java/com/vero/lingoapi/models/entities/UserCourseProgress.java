package com.vero.lingoapi.models.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Entidad de rompimiento (tabla de unión) que registra el progreso
 * individual de un usuario dentro de un curso específico.
 * <p>
 * Rompe la relación {@link ManyToMany} entre {@link AppUser} y
 * {@link Course} en una tabla intermedia con datos propios
 * (el nodo actual y la fecha de completitud), siguiendo el
 * principio de que las relaciones muchos-a-muchos nunca deben
 * tener una tabla intermedia sin atributos adicionales.
 * </p>
 *
 * <h2>Eliminación de redundancia</h2>
 * <p>
 * Sin esta tabla separada, las opciones habrían sido:
 * <ul>
 *   <li><b>Columnas repetidas en app_users:</b> {@code current_course_id}
 *       ya existe, pero si el usuario estudia 5 idiomas, necesitaríamos
 *       5 columnas ({@code course_1_id}, {@code course_2_id}…) con
 *       nombres semánticamente pobres y un límite artificial de 5.</li>
 *   <li><b>Array o JSON en app_users:</b> almacenar los progresos como
 *       JSON en una sola columna viola la 1FN, impide consultas
 *       eficientes ({@code ¿qué usuarios completaron el curso de francés?})
 *       y elimina la integridad referencial.</li>
 * </ul>
 * </p>
 *
 * <h2>Escalabilidad con N idiomas</h2>
 * <p>
 * Cada usuario puede aprender 2, 5 o 20 idiomas simultáneamente sin
 * cambiar el esquema de la base de datos. Simplemente se insertan
 * N filas en esta tabla (una por curso). Las consultas son directas
 * y eficientes gracias a los índices de las FK y el método
 * {@code findByUserIdAndCourseId()}.
 * </p>
 * <p>
 * Además, el campo {@code current_node_id} (FK hacia {@link LessonNode})
 * permite reanudar exactamente donde el usuario se quedó en cada
 * idioma, sin necesidad de almacenar el progreso como una cadena
 * JSON dentro de la fila del usuario.
 * </p>
 *
 * @see AppUser
 * @see Course
 * @see LessonNode
 */
@Entity
@Table(name = "user_course_progress",
       uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "course_id"}))
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserCourseProgress {

    /**
     * Identificador autoincremental de la fila de progreso.
     * Se usa {@link GenerationType#IDENTITY} porque PostgreSQL
     * soporta columnas SERIAL/BIGSERIAL nativas.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    /**
     * Usuario al que pertenece este registro de progreso.
     * Relación {@link ManyToOne} obligatoria.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private AppUser user;

    /**
     * Curso al que pertenece este registro de progreso.
     * Relación {@link ManyToOne} obligatoria.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    /**
     * Último nodo de lección que el usuario tiene desbloqueado
     * o activo dentro de este curso.
     * <p>
     * Relación {@link ManyToOne} opcional (puede ser {@code null}
     * si el usuario acaba de empezar el curso y aún no ha
     * desbloqueado ningún nodo).
     * </p>
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "current_node_id")
    private LessonNode currentLessonNode;

    /**
     * Fecha y hora en que el usuario completó el curso.
     * {@code null} si el curso está en progreso.
     * Útil para reportería: "¿cuántos usuarios terminaron
     * el curso de inglés este mes?"
     */
    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    /** Fecha de creación del registro (autogenerada). */
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /** Fecha de la última modificación (autogenerada). */
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
