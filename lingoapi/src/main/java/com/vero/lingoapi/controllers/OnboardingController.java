package com.vero.lingoapi.controllers;

import com.vero.lingoapi.models.dtos.OnboardingQuestionDTO;
import com.vero.lingoapi.services.OnboardingService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Controlador REST para el flujo de onboarding.
 * <p>
 * Provee las preguntas estáticas que el frontend muestra durante
 * la configuración inicial del perfil del usuario.
 * Delega la obtención de datos en {@link OnboardingService}.
 * </p>
 */
@RestController
@RequestMapping("/onboarding")
public class OnboardingController {

    private final OnboardingService onboardingService;

    public OnboardingController(OnboardingService onboardingService) {
        this.onboardingService = onboardingService;
    }

    /**
     * Retorna la lista de preguntas del cuestionario de onboarding.
     * <p>
     * Las preguntas son estáticas y están definidas en el servicio.
     * Este endpoint no requiere autenticación porque se usa durante
     * el flujo de registro inicial.
     * </p>
     *
     * @return 200 OK con la lista de preguntas
     */
    @GetMapping("/questions")
    public ResponseEntity<List<OnboardingQuestionDTO>> getQuestions() {
        List<OnboardingQuestionDTO> questions = onboardingService.getQuestions();
        return ResponseEntity.ok(questions);
    }
}
