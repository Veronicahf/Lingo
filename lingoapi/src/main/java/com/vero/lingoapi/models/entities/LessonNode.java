package com.vero.lingoapi.models.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Entidad que representa un nodo del mapa de lecciones (los círculos
 * o niveles que aparecen en el camino de aprendizaje del frontend).
 * <p>
 * Cada nodo pertenece exclusivamente a un {@link Course} y contiene
 * la información necesaria para renderizar el mapa: título, posición
 * en el mapa (nodeIndex), y coordenadas opcionales para la UI.
 * </p>
 *
 * <h2>Integridad referencial y ACID</h2>
 * <p>
 * La columna {@code course_id} es una clave foránea (FK) que
 * referencia a la PK de la tabla {@code courses}. Esta FK se define
 * con {@code nullable = false}, lo que significa que:
 * <ul>
 *   <li><b>Integridad de entidad:</b> todo nodo debe pertenecer
 *       a un curso existente. No se puede insertar un nodo con un
 *       {@code course_id} que no exista en la tabla padre.</li>
 *   <li><b>Integridad referencial:</b> la base de datos (PostgreSQL)
 *       impide eliminar un curso si existen nodos que lo referencian
 *       (a menos que se configure CASCADE). Esto evita
 *       <b>niveles huérfanos</b> — nodos sin un curso asociado.</li>
 *   <li><b>Atomicidad (ACID):</b> cualquier operación que cree o
 *       modifique un nodo se ejecuta dentro de una transacción.
 *       Si la FK es inválida, la transacción se revierte (rollback),
 *       garantizando que la base de datos nunca quede en un estado
 *       inconsistente.</li>
 *   <li><b>Consistencia:</b> el motor de BD verifica la FK en cada
 *       INSERT o UPDATE, manteniendo la relación lógica entre las
 *       tablas {@code lesson_node} y {@code courses}.</li>
 * </ul>
 * </p>
 * <p>
 * Sin esta FK, un bug en el código podría insertar nodos con un
 * {@code course_id} inválido, o eliminar un curso dejando decenas
 * de nodos huérfanos apuntando a la nada. La FK es la garantía
 * a nivel de base de datos de que esto no ocurre.
 * </p>
 *
 * @see Course
 */
@Entity
@Table(name = "lesson_nodes")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LessonNode {

    /**
     * Identificador único del nodo de lección.
     * Sigue el patrón {@code lesson_<curso>_<índice>}, ej:
     * {@code lesson_en_1}, {@code lesson_en_2}.
     */
    @Id
    @Column(name = "id", length = 64, nullable = false)
    private String id;

    /**
     * Título visible de la lección en el mapa del frontend
     * (ej. "¡Primeros pasos!", "Saludos y presentaciones").
     */
    @Column(name = "title", length = 255, nullable = false)
    private String title;

    /**
     * Índice numérico que determina la posición del nodo en el mapa.
     * Se usa para ordenar los nodos secuencialmente (1, 2, 3…)
     * y determinar qué nodo sigue después de completar el actual.
     */
    @Column(name = "node_index", nullable = false)
    private Integer nodeIndex;

    /**
     * Coordenadas de posición del nodo en la interfaz del mapa.
     * Almacenadas como VARCHAR en formato {@code "x,y"} (ej. {@code "120,340"}).
     * El frontend las usa para ubicar el círculo en el camino SVG.
     * Es opcional; si no se provee, el frontend puede calcular
     * la posición automáticamente basándose en el {@code nodeIndex}.
     */
    @Column(name = "coordinates", length = 32)
    private String coordinates;

    /**
     * Curso al que pertenece este nodo de lección.
     * <p>
     * Relación {@link ManyToOne} obligatoria ({@code nullable = false}).
     * La columna {@code course_id} es una FK hacia {@link Course#id}.
     * Como {@code nullable = false}, todo nodo debe tener un curso
     * asociado desde el momento de su creación, garantizando que
     * no existan niveles huérfanos en la base de datos.
     * </p>
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

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
