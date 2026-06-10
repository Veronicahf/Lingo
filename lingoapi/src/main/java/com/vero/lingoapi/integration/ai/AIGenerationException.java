package com.vero.lingoapi.integration.ai;

/**
 * Excepción personalizada para errores en la generación de lecciones por IA.
 * <p>
 * Se lanza cuando el cliente de IA ({@link AILessonClient}) no puede
 * completar una solicitud debido a timeouts, caídas del servicio externo,
 * respuestas malformadas o cualquier otro error de integración.
 * </p>
 * <p>
 * {@link com.vero.lingoapi.controllers.GlobalExceptionHandler} la captura
 * y la traduce a una respuesta HTTP 503 (Service Unavailable).
 * </p>
 */
public class AIGenerationException extends RuntimeException {

    /**
     * Construye una excepción con un mensaje descriptivo.
     *
     * @param message Descripción del error ocurrido
     */
    public AIGenerationException(String message) {
        super(message);
    }

    /**
     * Construye una excepción con mensaje y causa raíz.
     *
     * @param message Descripción del error
     * @param cause   Excepción original que provocó el fallo
     */
    public AIGenerationException(String message, Throwable cause) {
        super(message, cause);
    }
}
