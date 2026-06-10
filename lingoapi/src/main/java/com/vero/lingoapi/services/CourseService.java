package com.vero.lingoapi.services;

import com.vero.lingoapi.models.dtos.response.CourseDTO;
import com.vero.lingoapi.models.dtos.response.LessonNodeDTO;
import com.vero.lingoapi.models.entities.Course;
import com.vero.lingoapi.repositories.CourseRepository;
import com.vero.lingoapi.repositories.LessonNodeRepository;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Servicio encargado de la lógica de negocio para cursos y sus nodos
 * de lección (el mapa de aprendizaje).
 * <p>
 * Provee los catálogos que el frontend necesita para:
 * <ol>
 *   <li>Mostrar la pantalla de selección de idioma (lista de cursos).</li>
 *   <li>Renderizar el camino de aprendizaje (nodos ordenados de un curso).</li>
 * </ol>
 * </p>
 */
@Service
public class CourseService {

    private final CourseRepository courseRepository;
    private final LessonNodeRepository lessonNodeRepository;

    public CourseService(CourseRepository courseRepository,
                         LessonNodeRepository lessonNodeRepository) {
        this.courseRepository = courseRepository;
        this.lessonNodeRepository = lessonNodeRepository;
    }

    /**
     * Retorna todos los cursos de idiomas disponibles.
     * <p>
     * Itera sobre las entidades {@link Course} y las convierte a
     * {@link CourseDTO} para su serialización. Si no hay cursos,
     * retorna una lista vacía (no null).
     * </p>
     *
     * @return Lista de todos los cursos del catálogo
     */
    public List<CourseDTO> getAllCourses() {
        return courseRepository.findAll()
                .stream()
                .map(course -> new CourseDTO(
                        course.getId(),
                        course.getName(),
                        course.getDescription(),
                        course.getLanguageCode()
                ))
                .toList();
    }

    /**
     * Retorna los nodos de lección de un curso ordenados por índice.
     * <p>
     * El frontend consume este endpoint para dibujar el mapa: cada nodo
     * tiene coordenadas y un índice que define la secuencia. Si el
     * courseId no existe o el curso no tiene nodos, retorna lista vacía.
     * </p>
     *
     * @param courseId Identificador del curso (ej. "course_en")
     * @return Lista de nodos ordenados ascendentemente por nodeIndex
     */
    public List<LessonNodeDTO> getNodesByCourse(String courseId) {
        return lessonNodeRepository.findByCourseIdOrderByNodeIndexAsc(courseId)
                .stream()
                .map(node -> new LessonNodeDTO(
                        node.getId(),
                        node.getTitle(),
                        node.getNodeIndex(),
                        node.getCoordinates()
                ))
                .toList();
    }
}
