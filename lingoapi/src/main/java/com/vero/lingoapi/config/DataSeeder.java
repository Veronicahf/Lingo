package com.vero.lingoapi.config;

import com.vero.lingoapi.models.entities.Course;
import com.vero.lingoapi.models.entities.LessonNode;
import com.vero.lingoapi.repositories.CourseRepository;
import com.vero.lingoapi.repositories.LessonNodeRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

/**
 * Poblador inicial de la base de datos (seeder).
 * <p>
 * Implementa {@link CommandLineRunner}, una interfaz de Spring Boot
 * que ejecuta su método {@link #run(String...)} inmediatamente después
 * de que el contexto de la aplicación se haya inicializado por completo,
 * pero antes de que el servidor comience a aceptar peticiones HTTP.
 * </p>
 *
 * <h2>Ciclo de vida en Spring Boot</h2>
 * <ol>
 *   <li>Se invoca {@code SpringApplication.run()} → se levanta el
 *       contenedor de IoC, se crean todos los beans ({@code @Component},
 *       {@code @Service}, {@code @Repository}, etc.).</li>
 *   <li>Se inicializan los beans de infraestructura: fuente de datos,
 *       JPA, pool de conexiones.</li>
 *   <li>Hibernate ejecuta {@code ddl-auto=update} y sincroniza el
 *       esquema de la BD con las entidades.</li>
 *   <li>Spring Boot escanea todos los beans que implementan
 *       {@link CommandLineRunner} y ejecuta sus métodos {@code run()}.</li>
 *   <li>Finalmente, el contenedor web (Tomcat) se abre y empieza
 *       a aceptar peticiones en el puerto configurado.</li>
 * </ol>
 * <p>
 * Esto garantiza que cuando llegue la primera petición HTTP, la BD
 * ya tenga los datos semilla disponibles.
 * </p>
 *
 * <h2>Buena práctica para entornos de desarrollo</h2>
 * <p>
 * Usar un {@code CommandLineRunner} condicional (que verifica si la
 * BD está vacía antes de insertar) es preferible a scripts SQL
 * externos porque:
 * <ul>
 *   <li>El código Java es portátil entre bases de datos (PostgreSQL,
 *       H2 en tests, etc.). Un script SQL tendría que adaptarse a
 *       cada dialecto.</li>
 *   <li>La lógica condicional evita duplicados al reiniciar la
 *       aplicación (idempotencia).</li>
 *   <li>El seeder vive dentro del mismo artefacto JAR, no requiere
 *       una ejecución externa separada.</li>
 *   <li>Se puede desactivar fácilmente en producción eliminando la
 *       anotación {@code @Component} o usando {@code @Profile}.</li>
 * </ul>
 * </p>
 */
@Component
public class DataSeeder implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataSeeder.class);

    private final CourseRepository courseRepository;
    private final LessonNodeRepository lessonNodeRepository;

    public DataSeeder(CourseRepository courseRepository,
                      LessonNodeRepository lessonNodeRepository) {
        this.courseRepository = courseRepository;
        this.lessonNodeRepository = lessonNodeRepository;
    }

    /**
     * Ejecuta la inserción de datos iniciales si la BD está vacía.
     * <p>
     * El método es <b>idempotente</b>: si ya existen cursos en la
     * base de datos, no hace nada. Esto permite reiniciar la aplicación
     * múltiples veces sin insertar filas duplicadas.
     * </p>
     *
     * @param args Argumentos de línea de comandos (no se usan)
     */
    @Override
    public void run(String... args) {
        if (courseRepository.count() > 0) {
            log.info("La BD ya contiene cursos — se omite el seeder");
            return;
        }

        log.info("Insertando datos semilla...");

        // ──────────────────────────────────────────────
        // Cursos de idiomas
        // ──────────────────────────────────────────────
        Course ingles = Course.builder()
                .id("course_en")
                .name("Inglés")
                .description("Aprende inglés desde cero con lecciones interactivas")
                .languageCode("en")
                .build();

        Course frances = Course.builder()
                .id("course_fr")
                .name("Francés")
                .description("Découvrez la langue française avec Lingo")
                .languageCode("fr")
                .build();

        courseRepository.save(ingles);
        courseRepository.save(frances);
        log.info("Cursos insertados: {} (en), {} (fr)", ingles.getId(), frances.getId());

        // ──────────────────────────────────────────────
        // Nodos de lección para el curso de Inglés
        // ──────────────────────────────────────────────
        LessonNode node1 = LessonNode.builder()
                .id("node_en_1")
                .title("Fundamentos")
                .nodeIndex(1)
                .coordinates("100,200")
                .course(ingles)
                .build();

        LessonNode node2 = LessonNode.builder()
                .id("node_en_2")
                .title("Saludos")
                .nodeIndex(2)
                .coordinates("250,300")
                .course(ingles)
                .build();

        LessonNode node3 = LessonNode.builder()
                .id("node_en_3")
                .title("Comida")
                .nodeIndex(3)
                .coordinates("400,400")
                .course(ingles)
                .build();

        lessonNodeRepository.save(node1);
        lessonNodeRepository.save(node2);
        lessonNodeRepository.save(node3);
        log.info("Nodos de lección insertados: {} nodos para {}", 3, ingles.getName());

        log.info("Seeder completado exitosamente");
    }
}
