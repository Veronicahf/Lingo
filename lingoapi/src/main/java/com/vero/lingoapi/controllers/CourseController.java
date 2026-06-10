package com.vero.lingoapi.controllers;

import com.vero.lingoapi.models.dtos.response.CourseDTO;
import com.vero.lingoapi.models.dtos.response.LessonNodeDTO;
import com.vero.lingoapi.services.CourseService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para el catálogo de cursos y el mapa de aprendizaje.
 * <p>
 * Corresponde a los requerimientos del frontend para:
 * <ul>
 *   <li><b>Pantalla de selección de idioma:</b> {@code GET /courses}
 *       — muestra todos los idiomas disponibles.</li>
 *   <li><b>Mapa de lecciones (camino de aprendizaje):</b>
 *       {@code GET /courses/{courseId}/nodes} — retorna los nodos
 *       ordenados para dibujar el camino SVG.</li>
 * </ul>
 * Ambos endpoints están protegidos por {@link com.vero.lingoapi.security.FirebaseTokenFilter}
 * (requieren token Bearer válido).
 * </p>
 */
@RestController
@RequestMapping("/courses")
public class CourseController {

    private final CourseService courseService;

    public CourseController(CourseService courseService) {
        this.courseService = courseService;
    }

    /**
     * Retorna todos los cursos de idiomas disponibles en la plataforma.
     * <p>
     * <b>Frontend:</b> esta respuesta alimenta la pantalla donde el
     * usuario elige qué idioma aprender. Cada curso incluye su nombre,
     * descripción y código de idioma para mostrar la bandera.
     * </p>
     *
     * @return 200 OK con la lista de cursos
     */
    @GetMapping
    public ResponseEntity<List<CourseDTO>> getAllCourses() {
        List<CourseDTO> courses = courseService.getAllCourses();
        return ResponseEntity.ok(courses);
    }

    /**
     * Retorna los nodos de lección de un curso, ordenados por índice.
     * <p>
     * <b>Frontend:</b> estos datos se usan para renderizar el mapa
     * SVG del camino de aprendizaje. Cada nodo tiene un título,
     * una posición ordinal (nodeIndex) y coordenadas (x,y) para
     * ubicar el círculo en el SVG.
     * </p>
     *
     * @param courseId Identificador del curso (ej. "course_en")
     * @return 200 OK con la lista de nodos ordenados
     */
    @GetMapping("/{courseId}/nodes")
    public ResponseEntity<List<LessonNodeDTO>> getNodesByCourse(@PathVariable String courseId) {
        List<LessonNodeDTO> nodes = courseService.getNodesByCourse(courseId);
        return ResponseEntity.ok(nodes);
    }
}
