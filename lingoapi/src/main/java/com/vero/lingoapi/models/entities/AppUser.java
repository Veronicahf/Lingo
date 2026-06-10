package com.vero.lingoapi.models.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDateTime;

/**
 * Entidad que representa a un usuario registrado en Lingo.
 * <p>
 * El identificador principal ({@code id}) es el UID proporcionado por
 * Firebase Auth, por lo tanto es un {@link String} en lugar de un
 * {@link Long} autoincremental. Esto evita tener que mantener una
 * doble relación entre el UID de Firebase y un ID interno, simplificando
 * la lógica de autenticación y el mapeo con el frontend.
 * </p>
 * <p>
 * Se utiliza el patrón <b>Builder</b> (vía Lombok {@link Builder}) para
 * facilitar la creación de instancias con múltiples campos opcionales
 * y mejorar la legibilidad del código al construir objetos complejos.
 * </p>
 *
 * @see <a href="https://firebase.google.com/docs/auth">Firebase Auth</a>
 */
@Entity
@Table(name = "app_users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AppUser {

    /**
     * Identificador único del usuario, proveniente de Firebase Auth.
     * Se almacena como VARCHAR(128) porque los UIDs de Firebase tienen
     * una longitud variable (típicamente 28 caracteres, pero se deja
     * margen para futuros cambios en el proveedor de identidad).
     * <p>
     * <b>Decisión arquitectónica:</b> usar el UID de Firebase como PK
     * evita la necesidad de una tabla de mapeo UID-ID y elimina una
     * posible fuente de inconsistencias. El frontend ya conoce el UID
     * desde el momento del login con Firebase, por lo que todas las
     * consultas pueden hacerse directamente con este valor.
     * </p>
     */
    @Id
    @Column(name = "id", length = 128, nullable = false)
    private String id;

    /** Correo electrónico asociado a la cuenta de Firebase del usuario. */
    @Column(name = "email", length = 255, nullable = false)
    private String email;

    /** Nombre visible del usuario dentro de la plataforma. */
    @Column(name = "name", length = 255, nullable = false)
    private String name;

    /** URL pública del avatar o foto de perfil del usuario. */
    @Column(name = "avatar_url", length = 512)
    @Builder.Default
    private String avatarUrl = "";

    /** Días consecutivos de actividad (racha) para la gamificación. */
    @Column(name = "streak_days", nullable = false)
    @Builder.Default
    private Integer streakDays = 0;

    /** Cantidad de gemas (moneda virtual del juego). */
    @Column(name = "gems", nullable = false)
    @Builder.Default
    private Integer gems = 0;

    /** Puntos de experiencia totales acumulados por el usuario. */
    @Column(name = "total_xp", nullable = false)
    @Builder.Default
    private Integer totalXp = 0;

    /** Corazones restantes (vidas) para las lecciones. */
    @Column(name = "hearts", nullable = false)
    @Builder.Default
    private Integer hearts = 5;

    /**
     * Curso actualmente seleccionado por el usuario.
     * <p>
     * Relación {@link ManyToOne} hacia {@link Course}.
     * La columna {@code current_course_id} en la tabla {@code app_users}
     * es una clave foránea que referencia la PK de la tabla {@code courses}.
     * </p>
     * <p>
     * <b>Beneficio de normalización (2FN):</b> al separar los datos del
     * curso en su propia tabla, evitamos almacenar el nombre, descripción
     * y código de idioma repetidos en cada fila de usuario. Si en el futuro
     * se necesita cambiar el nombre de un curso, se actualiza una sola fila
     * en {@code courses} en lugar de miles de filas en {@code app_users}.
     * </p>
     * <p>
     * La anotación {@code @ToString.Exclude} evita que Lombok intente
     * cargar la relación {@code Course} al generar el toString(), previniendo
     * posibles excepciones de lazy loading en logs o depuración.
     * </p>
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "current_course_id")
    @ToString.Exclude
    @Builder.Default
    private Course currentCourse = null;

    /**
     * Fecha y hora de creación del registro.
     * Se asigna automáticamente en la primera persistencia
     * y no se modifica después.
     */
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /**
     * Fecha y hora de la última modificación del registro.
     * Se actualiza automáticamente en cada operación de actualización.
     */
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    /**
     * Asigna los timestamps {@link #createdAt} y {@link #updatedAt}
     * antes de la primera operación de persistencia.
     * Es invocado automáticamente por JPA.
     */
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    /**
     * Actualiza el timestamp {@link #updatedAt} antes de cada
     * operación de actualización.
     * Es invocado automáticamente por JPA.
     */
    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
