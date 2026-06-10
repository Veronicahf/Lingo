package com.vero.lingoapi.repositories;

import com.vero.lingoapi.models.entities.UserCourseProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio Spring Data JPA para la entidad {@link UserCourseProgress}.
 * <p>
 * Proporciona operaciones CRUD y consultas derivadas para acceder
 * al progreso individual de un usuario en un curso específico.
 * </p>
 */
@Repository
public interface UserCourseProgressRepository extends JpaRepository<UserCourseProgress, Long> {

    /**
     * Busca el progreso de un usuario en un curso específico.
     * <p>
     * El resultado es {@link Optional} porque un usuario puede
     * no haber iniciado aún el curso, en cuyo caso no existirá
     * una fila de progreso.
     * </p>
     *
     * @param userId   UID de Firebase del usuario
     * @param courseId Identificador del curso (ej. "course_en")
     * @return Optional con el progreso si existe
     */
    Optional<UserCourseProgress> findByUserIdAndCourseId(String userId, String courseId);
}
