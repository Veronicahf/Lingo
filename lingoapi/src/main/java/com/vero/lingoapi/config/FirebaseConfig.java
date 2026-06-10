package com.vero.lingoapi.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;

import java.io.InputStream;

/**
 * Configuración del Firebase Admin SDK.
 * <p>
 * Se ejecuta al iniciar la aplicación para inicializar la instancia
 * de FirebaseApp con las credenciales de la cuenta de servicio.
 * Lee el archivo JSON desde la ruta configurada en
 * {@code firebase.config.path} (por defecto classpath:firebase-service-account.json).
 * </p>
 * Si ya existe una instancia de FirebaseApp, no la duplica
 * (evita error en recargas del contexto).
 */
@Configuration
public class FirebaseConfig {

    private static final Logger log = LoggerFactory.getLogger(FirebaseConfig.class);

    @Value("${firebase.config.path}")
    private Resource firebaseConfigPath;

    /**
     * Inicializa Firebase App con las credenciales de servicio.
     * <p>
     * Lee el archivo JSON de la cuenta de servicio, construye las
     * opciones de Firebase y llama a {@link FirebaseApp#initializeApp(FirebaseOptions)}.
     * Si FirebaseApp ya fue inicializada (ej. reinicio del contexto),
     * omite la inicialización para evitar errores.
     * </p>
     */
    @PostConstruct
    public void initialize() {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                InputStream serviceAccount = firebaseConfigPath.getInputStream();

                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();

                FirebaseApp.initializeApp(options);
                log.info("Firebase Admin SDK inicializado correctamente");
            }
        } catch (Exception e) {
            log.error("Error al inicializar Firebase Admin SDK: {}", e.getMessage());
        }
    }
}
