package com.vero.lingoapi.services;

import com.vero.lingoapi.models.dtos.OnboardingQuestionDTO;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Servicio que provee las preguntas estáticas del flujo de onboarding.
 * <p>
 * Por ahora las preguntas están definidas en código como constantes.
 * En el futuro podrían obtenerse desde la base de datos si se requiere
 * administración dinámica de contenido.
 * </p>
 * Las preguntas están diseñadas para conocer la motivación, nivel y
 * disponibilidad del usuario al iniciar su aprendizaje en Lingo.
 */
@Service
public class OnboardingService {

    /**
     * Retorna la lista completa de preguntas de onboarding.
     * <p>
     * Cada pregunta tiene un identificador único, el texto en español
     * y una lista de opciones entre las que el usuario puede elegir.
     * Actualmente hay tres preguntas: motivo de aprendizaje, nivel
     * de conocimiento, y tiempo disponible diario.
     * </p>
     *
     * @return Lista inmutable de {@link OnboardingQuestionResponse}
     */
    public List<OnboardingQuestionDTO> getQuestions() {
        return List.of(
                new OnboardingQuestionDTO(
                        1,
                        "¿Por qué quieres aprender un nuevo idioma?",
                        List.of("Educación", "Viajes", "Trabajo", "Familia", "Otro")
                ),
                new OnboardingQuestionDTO(
                        2,
                        "¿Cuánto sabes del idioma que quieres aprender?",
                        List.of("Nada (Principiante)", "Un poco (Básico)", "Lo suficiente (Intermedio)", "Casi fluido (Avanzado)")
                ),
                new OnboardingQuestionDTO(
                        3,
                        "¿Cuántos minutos al día puedes dedicar?",
                        List.of("5 minutos", "10 minutos", "15 minutos", "30 minutos o más")
                )
        );
    }
}
