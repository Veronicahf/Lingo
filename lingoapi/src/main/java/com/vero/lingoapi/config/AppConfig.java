package com.vero.lingoapi.config;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Configuración global de beans de la aplicación.
 * <p>
 * Aquí se definen beans de propósito general que no pertenecen a
 * una capa específica (controladores, servicios, repositorios).
 * </p>
 *
 * <h2>ObjectMapper</h2>
 * <p>
 * Se define explícitamente un {@link ObjectMapper} como bean de Spring
 * para que cualquier servicio que lo necesite (como
 * {@link com.vero.lingoapi.services.LessonGenerationService}) pueda
 * inyectarlo sin depender de la auto-configuración de Spring Boot.
 * </p>
 * <p>
 * <b>¿Por qué es necesario declararlo?</b> Aunque Spring Boot auto-configura
 * un {@code ObjectMapper} cuando Jackson está en el classpath, algunos
 * contextos de prueba o configuraciones específicas pueden no tenerlo
 * disponible como bean. Declararlo explícitamente garantiza que siempre
 * haya un bean disponible, independientemente del perfil o entorno.
 * </p>
 * <p>
 * Configuraciones aplicadas:
 * <ul>
 *   <li>{@link SerializationFeature#WRITE_DATES_AS_TIMESTAMPS}: deshabilitado
 *       para que las fechas se serialicen como ISO-8601.</li>
 *   <li>{@link DeserializationFeature#FAIL_ON_UNKNOWN_PROPERTIES}: deshabilitado
 *       para tolerar campos desconocidos en respuestas de la IA.</li>
 *   <li>{@link JavaTimeModule}: registrado para soportar tipos
 *       {@code java.time.LocalDateTime}, {@code Instant}, etc.</li>
 * </ul>
 * </p>
 */
@Configuration
public class AppConfig {

    /**
     * Provee un {@link ObjectMapper} configurado para toda la aplicación.
     * <p>
     * Este bean es utilizado por {@link com.vero.lingoapi.services.LessonGenerationService}
     * para deserializar las respuestas JSON de la IA en objetos Java.
     * </p>
     *
     * @return ObjectMapper configurado con soporte de fechas ISO-8601
     *         y tolerancia a propiedades desconocidas
     */
    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();

        // Serializar fechas como ISO-8601 en lugar de timestamps numéricos
        mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

        // No fallar si el JSON contiene campos que no están en el DTO
        mapper.disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);

        // Soporte para tipos java.time (LocalDateTime, Instant, etc.)
        mapper.registerModule(new JavaTimeModule());

        return mapper;
    }
}
