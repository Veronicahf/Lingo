package com.vero.lingoapi.models.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Entidad que representa una actividad individual dentro de un
 * nodo de lección ({@link LessonNode}).
 * <p>
 * Cada actividad es una pregunta o ejercicio que el usuario debe
 * resolver. Los campos comunes a todos los tipos de actividad
 * (type, prompt, correctAnswer, etc.) están modelados como
 * columnas relacionales estrictas. El contenido dinámico y
 * variable según el tipo (opciones múltiples, pistas de audio,
 * rutas de imágenes, etc.) se almacena en el campo {@code payload}
 * como JSONB.
 * </p>
 *
 * <h2>Ventaja arquitectónica de JSONB para payloads dinámicos</h2>
 * <p>
 * En lugar de optar por uno de estos enfoques tradicionales:
 * </p>
 * <ul>
 *   <li><b>Herencia de tabla por clase (JOINs):</b> requeriría una
 *       tabla por cada tipo de actividad con columnas especializadas,
 *       multiplicando las tablas y exigiendo JOINs costosos en cada
 *       consulta de lección.</li>
 *   <li><b>Tabla única con columnas nullable:</b> desperdicio de
 *       espacio y violación de la 1FN (dependencias inexistentes
 *       entre columnas).</li>
 *   <li><b>Tabla EAV (Entity-Attribute-Value):</b> pesadilla de
 *       rendimiento y mantenimiento, filas sin tipo fijo.</li>
 * </ul>
 * <p>
 * <b>JSONB resuelve:</b>
 * <ul>
 *   <li><b>Esquema flexible:</b> cada tipo de actividad guarda solo
 *       los atributos que necesita. Una {@code translateSentence}
 *       guarda {@code {"options": ["hola", "adiós"]}}, mientras que
 *       {@code fillBlank} guarda {@code {"sentence": "Yo ___ inglés"}}.</li>
 *   <li><b>Indexación GIN:</b> PostgreSQL permite crear índices GIN
 *       sobre columnas JSONB para consultar dentro del JSON con
 *       operadores como {@code @>}, {@code ?}, {@code ?|}.</li>
 *   <li><b>Sin JOINs:</b> el payload viaja en la misma fila que los
 *       campos relacionales, eliminando la sobrecarga de uniones.</li>
 *   <li><b>Validación opcional:</b> se pueden agregar constraints
 *       CHECK({@code payload ? 'options'}) si se requiere validar
 *       la estructura por tipo a nivel de BD.</li>
 *   <li><b>Integración con la IA:</b> la IA generativa que produce
 *       estas actividades puede escribir JSON directamente sin pasar
 *       por un mapeo ORM rígido.</li>
 * </ul>
 * </p>
 *
 * @see ActivityType
 * @see LessonNode
 */
@Entity
@Table(name = "lesson_activities")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LessonActivity {

    /**
     * Identificador único de la actividad.
     * Sigue el patrón {@code act_<curso>_<nodo>_<índice>},
     * ej: {@code act_en_1_1}, {@code act_en_1_2}.
     */
    @Id
    @Column(name = "id", length = 64, nullable = false)
    private String id;

    /**
     * Tipo de actividad, determinado por el enum {@link ActivityType}.
     * Se almacena como String legible en la BD gracias a
     * {@code @Enumerated(EnumType.STRING)}.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "type", length = 32, nullable = false)
    private ActivityType type;

    /**
     * Texto de la instrucción o enunciado que ve el usuario
     * (ej. "Traduce la siguiente frase al inglés").
     */
    @Column(name = "prompt", length = 512, nullable = false)
    private String prompt;

    /**
     * Respuesta correcta esperada. Se usa para validar
     * automáticamente la respuesta del usuario.
     */
    @Column(name = "correct_answer", length = 255, nullable = false)
    private String correctAnswer;

    /**
     * Explicación generada por IA que se muestra al usuario
     * después de responder, ayudándole a entender por qué
     * su respuesta fue correcta o incorrecta.
     */
    @Column(name = "ai_explanation", length = 2048)
    private String aiExplanation;

    /**
     * Emoción que debe mostrar la mascota de Lingo mientras
     * se presenta esta actividad (ej. "happy", "thinking", "sad").
     */
    @Column(name = "mascot_emotion", length = 32)
    private String mascotEmotion;

    /**
     * Categoría gramatical o temática de la actividad
     * (ej. "vocabulario", "verbos", "presente_simple").
     */
    @Column(name = "category", length = 64)
    private String category;

    /**
     * Nodo de lección al que pertenece esta actividad.
     * Relación {@link ManyToOne} obligatoria: cada actividad
     * debe estar asociada a un nodo existente.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "node_id", nullable = false)
    private LessonNode node;

    /**
     * Payload dinámico de la actividad en formato JSONB.
     * <p>
     * Contiene la estructura variable según el tipo:
     * <ul>
     *   <li>{@code translateSentence}: {@code {"options": ["texto1","texto2"]}}</li>
     *   <li>{@code fillBlank}: {@code {"sentence": "Yo ___ inglés", "hints": ["pista1"]}}</li>
     *   <li>{@code listenSelect}: {@code {"audioUrl": "...", "options": ["...","..."]}}</li>
     *   <li>{@code speaking}: {@code {"expectedAudio": "...", "tolerance": 0.8}}</li>
     * </ul>
     * </p>
     * <p>
     * Se mapea como String de Java pero con {@code columnDefinition = "jsonb"}
     * para que Hibernate cree la columna con el tipo nativo JSONB de PostgreSQL.
     * La serialización/deserialización del JSON queda a cargo del código
     * Java (Jackson) en lugar del ORM.
     * </p>
     */
    @Column(name = "payload", columnDefinition = "jsonb")
    private String payload;

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
