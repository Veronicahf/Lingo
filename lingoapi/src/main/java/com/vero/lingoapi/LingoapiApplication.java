package com.vero.lingoapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Clase principal de la aplicación Lingo API.
 * <p>
 * Inicializa el contexto de Spring Boot, escanea automáticamente
 * los paquetes {@code controllers}, {@code services},
 * {@code repositories}, {@code models}, {@code security}
 * y {@code config} para descubrir y registrar todos los beans.
 * </p>
 */
@SpringBootApplication
public class LingoapiApplication {

    /**
     * Punto de entrada de la aplicación.
     * Arranca el contenedor embebido de Tomcat y levanta el contexto
     * de Spring con toda la configuración de la aplicación.
     *
     * @param args Argumentos de línea de comandos
     */
    public static void main(String[] args) {
        SpringApplication.run(LingoapiApplication.class, args);
    }
}
