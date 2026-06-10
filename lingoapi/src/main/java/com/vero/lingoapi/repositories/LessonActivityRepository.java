package com.vero.lingoapi.repositories;

import com.vero.lingoapi.models.entities.LessonActivity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio Spring Data JPA para la entidad {@link LessonActivity}.
 * <p>
 * Proporciona operaciones CRUD y consultas derivadas para recuperar
 * las actividades de un nodo de lección específico.
 * </p>
 */
@Repository
public interface LessonActivityRepository extends JpaRepository<LessonActivity, String> {

    /**
     * Retorna todas las actividades asociadas a un nodo de lección,
     * ordenadas por su identificador (que sigue el patrón secuencial
     * {@code act_<curso>_<nodo>_<índice>}).
     *
     * @param nodeId Identificador del nodo de lección
     * @return Lista de actividades del nodo
     */
    List<LessonActivity> findByNodeIdOrderByIdAsc(String nodeId);
}
