package com.vero.lingoapi.controllers;

import com.vero.lingoapi.models.dtos.response.LessonActivityDTO;
import com.vero.lingoapi.services.LessonGenerationService;
import com.vero.lingoapi.services.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para la generación y entrega de actividades de lección.
 * <p>
 * Expone el endpoint {@code GET /nodes/{nodeId}/activities} que el frontend
 * consume para obtener los ejercicios de un nodo específico del mapa de
 * aprendizaje.
 * </p>
 *
 * <h2>⚠️ Endpoint más pesado del sistema</h2>
 * <p>
 * Este es el endpoint con mayor latencia de toda la API porque cada
 * llamada dispara una petición síncrona a la API de IA (OpenAI, Gemini,
 * Claude, etc.). Dependiendo del proveedor y el modelo, la respuesta
 * puede demorar entre <b>2 y 15 segundos</b>.
 * </p>
 *
 * <h3>Recomendación futura: caché y pre-fetching</h3>
 * <p>
 * Para mitigar el impacto en la experiencia del usuario cuando la
 * aplicación escale, se recomienda:
 * <ul>
 *   <li><b>Caché con Redis:</b> una vez generadas las actividades para
 *       un nodo, almacenarlas en Redis con TTL (ej. 24h). Así, la
 *       siguiente solicitud al mismo nodo no requiere una nueva llamada
 *       a la IA.</li>
 *   <li><b>Generación asíncrona (pre-fetching):</b> cuando el usuario
 *       completa una lección, un proceso en segundo plano genera las
 *       actividades del siguiente nodo antes de que el usuario haga
 *       clic en él.</li>
 *   <li><b>Timeout elevado:</b> el cliente HTTP del backend debe tener
 *       un timeout de lectura de al menos 30 segundos (ya configurado
 *       en {@link com.vero.lingoapi.integration.ai.GenericLLMClient}).</li>
 * </ul>
 * </p>
 *
 * @see LessonGenerationService
 */
@RestController
@RequestMapping("/nodes")
public class LessonController {

    private final LessonGenerationService lessonGenerationService;
    private final UserService userService;

    public LessonController(LessonGenerationService lessonGenerationService,
                            UserService userService) {
        this.lessonGenerationService = lessonGenerationService;
        this.userService = userService;
    }

    /**
     * Genera y retorna las actividades de un nodo de lección.
     * <p>
     * <b>Resolución del courseId:</b>
     * <ol>
     *   <li>Si el frontend envía {@code ?courseId=course_en} como
     *       query parameter, se usa ese valor directamente.</li>
     *   <li>Si no se envía, se extrae el UID del usuario autenticado
     *       desde el {@link SecurityContextHolder} (establecido por
     *       {@link com.vero.lingoapi.security.FirebaseTokenFilter})
     *       y se consulta su curso actual en la base de datos.</li>
     * </ol>
     * </p>
     *
     * @param nodeId   Identificador del nodo de lección (path variable)
     * @param courseId Identificador del curso (query parameter opcional)
     * @return 200 OK con la lista de actividades generadas por IA,
     *         o 503 Service Unavailable si la IA falla
     */
    @GetMapping("/{nodeId}/activities")
    public ResponseEntity<List<LessonActivityDTO>> getActivities(
            @PathVariable String nodeId,
            @RequestParam(required = false) String courseId) {

        if (courseId == null || courseId.isBlank()) {
            String uid = (String) SecurityContextHolder.getContext()
                    .getAuthentication().getPrincipal();

            var profile = userService.getProfile(uid);
            courseId = profile.currentCourseId();
        }

        List<LessonActivityDTO> activities =
                lessonGenerationService.generateActivitiesForNode(courseId, nodeId);

        return ResponseEntity.ok(activities);
    }
}
