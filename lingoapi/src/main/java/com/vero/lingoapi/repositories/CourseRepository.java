package com.vero.lingoapi.repositories;

import com.vero.lingoapi.models.entities.Course;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio Spring Data JPA para la entidad {@link Course}.
 * <p>
 * Proporciona operaciones CRUD básicas sobre el catálogo de cursos
 * de idiomas. Al ser una tabla de referencia (maestra), los cursos
 * se crean manualmente (vía script SQL inicial o admin) y rara vez
 * se modifican.
 * </p>
 */
@Repository
public interface CourseRepository extends JpaRepository<Course, String> {
}
