package com.vero.lingoapi.models.dtos;

import java.util.List;

/**
 * DTO que representa una pregunta del cuestionario de onboarding.
 * <p>
 * Contiene el texto de la pregunta y las opciones de respuesta
 * disponibles. Estas preguntas son estáticas y se devuelven al
 * frontend durante el flujo de registro inicial.
 * </p>
 *
 * @param id           Identificador numérico de la pregunta
 * @param questionText Texto de la pregunta en español
 * @param options      Lista de opciones de respuesta disponibles
 */
public record OnboardingQuestionDTO(
        int id,
        String questionText,
        List<String> options
) {
}
