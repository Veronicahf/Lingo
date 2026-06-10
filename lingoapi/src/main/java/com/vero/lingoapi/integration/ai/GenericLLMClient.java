package com.vero.lingoapi.integration.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

/**
 * Cliente para la API de Google Gemini.
 * <p>
 * Implementa {@link AILessonClient} usando {@link RestTemplate} para
 * realizar peticiones POST al endpoint de Gemini 2.0 Flash.
 * </p>
 *
 * <h2>Diferencias con OpenAI</h2>
 * <ul>
 *   <li><b>Autenticación:</b> Gemini usa {@code x-goog-api-key}
 *       en lugar de {@code Authorization: Bearer}.</li>
 *   <li><b>Payload:</b> utiliza {@code system_instruction} para el
 *       prompt de sistema y {@code contents} para el mensaje de usuario.</li>
 *   <li><b>Respuesta:</b> el texto generado está en
 *       {@code candidates[0].content.parts[0].text}.</li>
 * </ul>
 *
 * <p>
 * {@link ObjectMapper} se usa para parsear la respuesta JSON de Gemini
 * de forma segura y navegar por el árbol con {@link JsonNode}, evitando
 * casteos inseguros y NullPointerException.
 * </p>
 *
 * @see AILessonClient
 */
@Component
public class GenericLLMClient implements AILessonClient {

    private static final Logger log = LoggerFactory.getLogger(GenericLLMClient.class);

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final String apiUrl;
    private final String apiKey;

    public GenericLLMClient(
            @Value("${ai.api.url}") String apiUrl,
            @Value("${ai.api.key}") String apiKey,
            ObjectMapper objectMapper) {
        this.restTemplate = new RestTemplate();
        this.apiUrl = apiUrl;
        this.apiKey = apiKey;
        this.objectMapper = objectMapper;

        var factory = restTemplate.getRequestFactory();
        if (factory instanceof org.springframework.http.client.SimpleClientHttpRequestFactory simpleFactory) {
            simpleFactory.setConnectTimeout(10_000);
            simpleFactory.setReadTimeout(30_000);
        }
    }

    /**
     * Envía un prompt a Gemini 2.0 Flash y retorna el JSON generado.
     *
     * @param systemPrompt Prompt de sistema con las instrucciones detalladas
     * @return String con el JSON de actividades generado por el modelo
     * @throws AIGenerationException si la IA falla, hay timeout o la respuesta es inválida
     */
    @Override
    public String generateLessonJson(String systemPrompt) {
        try {
            var requestBody = buildRequestBody(systemPrompt);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("x-goog-api-key", apiKey);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);

            log.debug("🚀 Enviando prompt a Gemini 3 Flash en: {}", apiUrl);

            ResponseEntity<String> response = restTemplate.exchange(
                    apiUrl,
                    HttpMethod.POST,
                    request,
                    String.class
            );

            String content = extractContent(response.getBody());
            log.info("Respuesta de Gemini recibida ({} caracteres)", content.length());

            return content;

        } catch (ResourceAccessException e) {
            log.error("Timeout o error de conexión con Gemini: {}", e.getMessage());
            throw new AIGenerationException(
                    "El servicio de IA no está disponible en este momento (timeout). Intente nuevamente.", e);

        } catch (RestClientException e) {
            String responseBody = "";
            if (e instanceof org.springframework.web.client.HttpStatusCodeException statusEx) {
                responseBody = statusEx.getResponseBodyAsString();
            }
            log.error("Error en la comunicación con Gemini. Código: {}. Body: {}",
                    e.getMessage(), responseBody);
            throw new AIGenerationException(
                    "Error al comunicarse con el servicio de IA: " + e.getMessage(), e);

        } catch (Exception e) {
            log.error("Error inesperado al generar lección con Gemini: {}", e.getMessage());
            throw new AIGenerationException(
                    "Error interno al generar la lección. Intente nuevamente.", e);
        }
    }

    /**
     * Construye el cuerpo de la petición en el formato que espera Gemini 1.5.
     * <p>
     * Gemini separa las instrucciones del sistema ({@code system_instruction})
     * del mensaje del usuario ({@code contents}), a diferencia de OpenAI
     * que lo trata como un array plano de {@code messages}.
     * </p>
     *
     * @param systemPrompt Prompt de sistema detallado para el modelo
     * @return Mapa con la estructura {@code {system_instruction, contents}}
     */
    private Map<String, Object> buildRequestBody(String systemPrompt) {
        return Map.of(
                "system_instruction", Map.of(
                        "parts", List.of(Map.of("text", systemPrompt))
                ),
                "contents", List.of(Map.of(
                        "parts", List.of(Map.of(
                                "text", "Genera las 10 actividades estrictamente en un arreglo JSON. " +
                                        "Solo devuelve el JSON, sin explicaciones ni notas."
                        ))
                ))
        );
    }

    /**
     * Extrae el texto generado por Gemini desde la respuesta JSON.
     * <p>
     * Navega por el árbol de la respuesta de Gemini usando {@link JsonNode}:
     * <pre>
     * candidates[0].content.parts[0].text
     * </pre>
     * Este enfoque es más seguro que castear {@code Map} porque:
     * <ul>
     *   <li>{@link JsonNode#path(String)} nunca lanza excepción:
     *       si la ruta no existe, retorna un nodo "missing" en lugar de null.</li>
     *   <li>El método {@code asText()} evita NullPointerException:
     *       si el nodo es missing o null, retorna cadena vacía.</li>
     *   <li>No requiere supresiones de warnings ni casteos unchecked.</li>
     * </ul>
     * </p>
     *
     * @param responseBody Respuesta JSON cruda de Gemini
     * @return El texto generado por el modelo
     * @throws AIGenerationException si la respuesta no tiene la estructura esperada
     */
    private String extractContent(String responseBody) {
        if (responseBody == null || responseBody.isBlank()) {
            throw new AIGenerationException("Gemini devolvió una respuesta vacía");
        }

        try {
            JsonNode root = objectMapper.readTree(responseBody);

            JsonNode textNode = root.path("candidates")
                    .get(0)
                    .path("content")
                    .path("parts")
                    .get(0)
                    .path("text");

            String content = textNode.asText();

            if (content.isBlank()) {
                throw new AIGenerationException(
                        "Gemini devolvió contenido vacío en la respuesta: " + responseBody);
            }

            return content;

        } catch (AIGenerationException e) {
            throw e;

        } catch (Exception e) {
            log.error("Error al parsear respuesta de Gemini: {}", e.getMessage());
            throw new AIGenerationException(
                    "No se pudo interpretar la respuesta de Gemini. Intente nuevamente.", e);
        }
    }
}
