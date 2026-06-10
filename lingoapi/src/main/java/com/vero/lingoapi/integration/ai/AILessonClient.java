package com.vero.lingoapi.integration.ai;

/**
 * Interfaz que define el contrato para la generación de lecciones
 * utilizando un modelo de lenguaje (LLM).
 * <p>
 * Sirve como abstracción sobre cualquier proveedor de IA (OpenAI,
 * Gemini, Claude, etc.). Las implementaciones concretas se encargan
 * de construir la petición HTTP, manejar la autenticación y parsear
 * la respuesta del proveedor específico.
 * </p>
 * <p>
 * Beneficio del patrón <b>Strategy</b>: si en el futuro se cambia
 * de proveedor de IA, solo se crea una nueva implementación de
 * esta interfaz sin modificar el resto del sistema.
 * </p>
 */
public interface AILessonClient {

    /**
     * Envía un prompt a la IA y retorna el JSON generado con las
     * actividades de la lección.
     * <p>
     * El prompt debe incluir el contexto completo (idioma, nivel,
     * tipo de actividad, número de ejercicios, etc.) y la IA
     * responderá con un JSON estructurado que el servicio
     * {@code LessonService} parseará para crear las entidades
     * {@code LessonActivity}.
     * </p>
     *
     * @param prompt Prompt de sistema detallado con las instrucciones
     *               para la generación de la lección
     * @return String con el JSON de actividades generado por la IA
     * @throws AIGenerationException si la IA no responde, hay timeout,
     *                               o la respuesta no es procesable
     */
    String generateLessonJson(String prompt);
}
