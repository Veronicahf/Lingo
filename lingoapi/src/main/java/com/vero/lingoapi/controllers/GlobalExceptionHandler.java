package com.vero.lingoapi.controllers;

import com.vero.lingoapi.integration.ai.AIGenerationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Map;
import java.util.NoSuchElementException;

/**
 * Manejador global de excepciones para toda la aplicación.
 * <p>
 * Captura las excepciones lanzadas por los controladores y servicios,
 * y las traduce a respuestas HTTP con el código de estado adecuado.
 * Implementa el patrón de diseño "Factory Method" tácitamente al
 * construir respuestas de error según el tipo de excepción.
 * </p>
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Maneja excepciones de tipo {@link IllegalArgumentException}.
     * <p>
     * Se usa típicamente cuando se intenta registrar un UID duplicado.
     * Retorna HTTP 409 (Conflict) con un mensaje descriptivo.
     * </p>
     *
     * @param ex Excepción capturada
     * @return 409 Conflict con el mensaje de error
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleIllegalArgument(IllegalArgumentException ex) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(Map.of("error", ex.getMessage()));
    }

    /**
     * Maneja excepciones de tipo {@link NoSuchElementException}.
     * <p>
     * Se usa cuando no se encuentra un recurso solicitado (ej. usuario no existente).
     * Retorna HTTP 404 (Not Found).
     * </p>
     *
     * @param ex Excepción capturada
     * @return 404 Not Found con el mensaje de error
     */
    @ExceptionHandler(NoSuchElementException.class)
    public ResponseEntity<Map<String, String>> handleNoSuchElement(NoSuchElementException ex) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(Map.of("error", ex.getMessage()));
    }

    /**
     * Maneja excepciones de integración con la IA.
     * <p>
     * Se activa cuando el cliente {@link com.vero.lingoapi.integration.ai.GenericLLMClient}
     * no puede generar una lección por timeout, caída del servicio externo
     * o respuesta malformada. Retorna HTTP 503 (Service Unavailable)
     * para que el frontend muestre un mensaje amigable al usuario.
     * </p>
     *
     * @param ex Excepción de generación de IA
     * @return 503 Service Unavailable con el mensaje de error
     */
    @ExceptionHandler(AIGenerationException.class)
    public ResponseEntity<Map<String, String>> handleAIGeneration(AIGenerationException ex) {
        return ResponseEntity
                .status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(Map.of("error", ex.getMessage()));
    }

    /**
     * Maneja errores de validación de {@link jakarta.validation.Valid}.
     * <p>
     * Se activa cuando un DTO no pasa las validaciones (ej. email mal formado).
     * Retorna HTTP 400 (Bad Request) con el mensaje de error del primer campo inválido.
     * </p>
     *
     * @param ex Excepción de validación
     * @return 400 Bad Request con el mensaje de error de validación
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidation(MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult().getFieldErrors().stream()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .findFirst()
                .orElse("Error de validación");

        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(Map.of("error", message));
    }
}
