package com.vero.lingoapi.repositories;

import com.vero.lingoapi.models.entities.LessonNode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio Spring Data JPA para la entidad {@link LessonNode}.
 * <p>
 * Proporciona operaciones CRUD y métodos de consulta derivados
 * para localizar nodos por curso y ordenarlos por índice.
 * </p>
 */
@Repository
public interface LessonNodeRepository extends JpaRepository<LessonNode, String> {

    /**
     * Retorna todos los nodos de lección de un curso ordenados
     * por su índice de posición en el mapa.
     * <p>
     * Este método es clave para que el frontend renderice el
     * camino de aprendizaje en el orden correcto, desde el
     * nodo inicial (nodeIndex = 1) hasta el final.
     * </p>
     *
     * @param courseId Identificador del curso (ej. "course_en")
     * @return Lista de nodos ordenados por nodeIndex ascendente
     */
    List<LessonNode> findByCourseIdOrderByNodeIndexAsc(String courseId);
}
