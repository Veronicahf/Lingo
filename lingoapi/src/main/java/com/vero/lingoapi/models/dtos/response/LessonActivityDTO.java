package com.vero.lingoapi.models.dtos.response;

import com.vero.lingoapi.models.entities.ActivityType;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.Map;

/**
 * DTO que representa una actividad de lección generada por IA.
 * <p>
 * Refleja exactamente la estructura que el frontend (Flutter) espera
 * recibir para renderizar cada ejercicio. El campo {@code payload}
 * es un {@link Map} dinámico cuyo contenido varía según el
 * {@code type} (opciones múltiples, audio, texto, etc.).
 * </p>
 * <p>
 * La anotación {@link JsonIgnoreProperties @JsonIgnoreProperties(ignoreUnknown = true)}
 * permite que Jackson ignore campos adicionales que la IA pudiera
 * incluir en el JSON, evitando errores de deserialización sin
 * necesidad de un esquema rígido.
 * </p>
 *
 * @param id             Identificador único de la actividad dentro de la lección
 * @param type           Tipo de actividad (translateSentence, fillBlank, etc.)
 * @param prompt         Enunciado o instrucción visible para el usuario
 * @param correctAnswer  Respuesta correcta esperada
 * @param aiExplanation  Explicación generada por la IA (se muestra al finalizar)
 * @param mascotEmotion  Emoción de la mascota (happy, thinking, sad)
 * @param category       Categoría gramatical (vocabulario, verbos, etc.)
 * @param payload        Mapa dinámico con datos específicos según el tipo
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record LessonActivityDTO(
        String id,
        ActivityType type,
        String prompt,
        String correctAnswer,
        String aiExplanation,
        String mascotEmotion,
        String category,
        Map<String, Object> payload
) {
}
