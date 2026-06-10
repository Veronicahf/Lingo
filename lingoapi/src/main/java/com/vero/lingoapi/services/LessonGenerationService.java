package com.vero.lingoapi.services;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vero.lingoapi.integration.ai.AILessonClient;
import com.vero.lingoapi.integration.ai.AIGenerationException;
import com.vero.lingoapi.models.dtos.response.LessonActivityDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Servicio que orquesta la generación dinámica de lecciones usando IA.
 * <p>
 * Este es el "cerebro" del motor de lecciones: construye el prompt
 * pedagógico, lo envía al cliente de IA ({@link AILessonClient}),
 * recibe el JSON de respuesta y lo deserializa en una lista de
 * {@link LessonActivityDTO} que el frontend puede renderizar.
 * </p>
 *
 * <h2>Por qué ObjectMapper y no parseo manual</h2>
 * <p>
 * Deserializar manualmente el JSON de la IA con operaciones de
 * String (split, indexOf, expresiones regulares) es extremadamente
 * frágil. La IA puede devolver espacios extra, cambiar el orden
 * de los campos, o incluir caracteres de escape inesperados.
 * </p>
 * <p>
 * {@link ObjectMapper} resuelve esto porque:
 * <ul>
 *   <li><b>Mapeo por tipo:</b> usa {@link TypeReference} para
 *       deserializar directamente a {@code List<LessonActivityDTO>}
 *       sin necesidad de recorrer manualmente el JSON.</li>
 *   <li><b>Tolerancia a campos extra:</b> gracias a
 *       {@code @JsonIgnoreProperties(ignoreUnknown = true)} en el DTO,
 *       Jackson ignora campos que la IA incluya de más sin lanzar
 *       excepción.</li>
 *   <li><b>Coerción de tipos:</b> Jackson convierte automáticamente
 *       strings a enums, números a enteros, etc.</li>
 *   <li><b>Manejo de errores:</b> si el JSON es inválido, Jackson
 *       lanza una excepción descriptiva con la ubicación exacta del
 *       error, que se traduce a {@link AIGenerationException}.</li>
 * </ul>
 * </p>
 */
@Service
public class LessonGenerationService {

    private static final Logger log = LoggerFactory.getLogger(LessonGenerationService.class);

    private final AILessonClient aiLessonClient;
    private final ObjectMapper objectMapper;

    public LessonGenerationService(AILessonClient aiLessonClient, ObjectMapper objectMapper) {
        this.aiLessonClient = aiLessonClient;
        this.objectMapper = objectMapper;
    }

    /**
     * Genera dinámicamente una lista de actividades para un nodo de lección.
     * <p>
     * <b>Flujo completo:</b>
     * <ol>
     *   <li>Construye un prompt pedagógico detallado con las reglas
     *       de generación (tipos de actividad, cantidad, formato).</li>
     *   <li>Envía el prompt a la IA vía {@link AILessonClient}.</li>
     *   <li>Recibe un String JSON con la respuesta.</li>
     *   <li>Limpia el String (elimina posibles backticks o etiquetas
     *       Markdown que la IA pudiera añadir).</li>
     *   <li>Deserializa el JSON a {@code List<LessonActivityDTO>}
     *       usando {@link ObjectMapper}.</li>
     *   <li>Retorna la lista de actividades al controlador.</li>
     * </ol>
     * </p>
     *
     * @param courseId Identificador del curso (ej. "course_en")
     * @param nodeId   Identificador del nodo de lección (ej. "node_en_1")
     * @return Lista de actividades generadas por IA
     * @throws AIGenerationException si la IA falla o el JSON no es parseable
     */
    public List<LessonActivityDTO> generateActivitiesForNode(String courseId, String nodeId) {
        String prompt = buildPrompt(courseId, nodeId);

        log.info("Generando actividades para {} / {}...", courseId, nodeId);
        String rawJson = aiLessonClient.generateLessonJson(prompt);

        // ── Limpieza del JSON ──
        // La IA a veces envuelve el JSON en bloques Markdown (```json ... ```)
        // o añade texto explicativo antes/después. Se extrae solo el arreglo.
        String cleanedJson = cleanJsonResponse(rawJson);

        // ── Deserialización con ObjectMapper ──
        try {
            List<LessonActivityDTO> activities = objectMapper.readValue(
                    cleanedJson,
                    new TypeReference<List<LessonActivityDTO>>() {}
            );
            log.info("Actividades generadas exitosamente: {}", activities.size());
            return activities;

        } catch (Exception e) {
            log.error("Error al parsear JSON de la IA: {}", e.getMessage());
            throw new AIGenerationException(
                    "La respuesta de la IA no pudo ser interpretada. " +
                    "Intente nuevamente.", e);
        }
    }

    /**
     * Construye el prompt de sistema que se envía a la IA.
     * <p>
     * <b>Reglas de negocio del prompt:</b>
     * <ul>
     *   <li>La IA debe actuar como un profesor de idiomas experto.</li>
     *   <li>Debe generar <b>exactamente 10 actividades</b>.</li>
     *   <li>Debe incluir <b>al menos 1 actividad de cada tipo</b>
     *       del enum: {@code translateSentence}, {@code listenSelect},
     *       {@code fillBlank}, {@code speaking}, {@code selectTranslation}.</li>
     *   <li>Las 5 actividades restantes pueden ser de cualquier tipo,
     *       para dar variedad a la lección.</li>
     *   <li>Debe retornar <b>exclusivamente</b> un arreglo JSON crudo,
     *       sin bloques Markdown, sin comillas invertidas, sin etiquetas
     *       HTML y sin texto explicativo antes o después del JSON.</li>
     * </ul>
     * </p>
     *
     * @param courseId Identificador del curso
     * @param nodeId   Identificador del nodo de lección
     * @return Prompt listo para enviar a la IA
     */
    private String buildPrompt(String courseId, String nodeId) {
        return """
                Eres un profesor de idiomas experto y creativo.
                Tu tarea es generar EXACTAMENTE 10 actividades de aprendizaje
                para la lección "%s" del curso "%s".

                ## REQUISITOS OBLIGATORIOS:
                1. Genera SIEMPRE al menos UNA actividad de CADA uno de estos tipos:
                   - translateSentence
                   - listenSelect
                   - fillBlank
                   - speaking
                   - selectTranslation
                2. Las 5 actividades restantes puedes elegirlas libremente entre
                   los tipos anteriores para dar variedad.
                3. Asigna un 'id' único a cada actividad con el formato "act_%%d"
                   (ej. "act_1", "act_2").
                4. El campo 'payload' debe contener un objeto JSON con los
                   datos específicos según el tipo:
                   - translateSentence: {"options": ["opción1", "opción2", ...]}
                   - listenSelect:     {"audioUrl": "...", "options": [...]}
                   - fillBlank:        {"sentence": "La frase con ___ blanco", "hints": ["pista1"]}
                   - speaking:         {"expectedText": "texto a pronunciar"}
                   - selectTranslation:{"options": ["opción1", "opción2", ...]}
                5. Asigna 'mascotEmotion' según la dificultad:
                   "happy" para fáciles, "thinking" para medias, "sad" para difíciles.
                6. El campo 'category' debe clasificar la actividad
                   (ej. "vocabulario", "gramática", "verbos", "pronunciación").

                ## FORMATO DE SALIDA:
                Devuelve ÚNICAMENTE un arreglo JSON válido. Sin Markdown,
                sin bloques de código, sin etiquetas, sin texto adicional.
                Ni antes ni después del JSON.
                """.formatted(nodeId, courseId);
    }

    /**
     * Limpia la respuesta cruda de la IA extrayendo solo el JSON.
     * <p>
     * La IA a veces envuelve el JSON en bloques de código Markdown
     * (```json ... ```) o añade texto explicativo. Este método
     * extrae el contenido entre el primer '[' y el último ']'
     * para obtener el arreglo JSON limpio.
     * </p>
     *
     * @param raw Response cruda de la IA
     * @return Solo el arreglo JSON sin adornos
     * @throws AIGenerationException si no se encuentra un arreglo JSON
     */
    private String cleanJsonResponse(String raw) {
        if (raw == null || raw.isBlank()) {
            throw new AIGenerationException("La IA devolvió una respuesta vacía");
        }

        int start = raw.indexOf('[');
        int end = raw.lastIndexOf(']');

        if (start == -1 || end == -1 || end <= start) {
            throw new AIGenerationException(
                    "La IA no devolvió un arreglo JSON válido: " + raw);
        }

        return raw.substring(start, end + 1);
    }
}
