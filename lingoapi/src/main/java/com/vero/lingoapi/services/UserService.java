package com.vero.lingoapi.services;

import com.vero.lingoapi.models.dtos.UserProfileDTO;
import com.vero.lingoapi.models.dtos.UserRegisterDTO;
import com.vero.lingoapi.models.entities.AppUser;
import com.vero.lingoapi.models.entities.Course;
import com.vero.lingoapi.models.entities.LessonNode;
import com.vero.lingoapi.models.entities.UserCourseProgress;
import com.vero.lingoapi.repositories.CourseRepository;
import com.vero.lingoapi.repositories.LessonNodeRepository;
import com.vero.lingoapi.repositories.UserCourseProgressRepository;
import com.vero.lingoapi.repositories.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.NoSuchElementException;

/**
 * Servicio encargado de la lógica de negocio relacionada con usuarios.
 * <p>
 * Agrupa las operaciones de registro, consulta de perfil y verificación
 * de existencia. Cada método orquesta la interacción con los repositorios
 * y construye los DTOs de respuesta.
 * </p>
 */
@Service
public class UserService {

    private final UserRepository userRepository;
    private final CourseRepository courseRepository;
    private final LessonNodeRepository lessonNodeRepository;
    private final UserCourseProgressRepository progressRepository;

    public UserService(UserRepository userRepository,
                       CourseRepository courseRepository,
                       LessonNodeRepository lessonNodeRepository,
                       UserCourseProgressRepository progressRepository) {
        this.userRepository = userRepository;
        this.courseRepository = courseRepository;
        this.lessonNodeRepository = lessonNodeRepository;
        this.progressRepository = progressRepository;
    }

    /**
     * Registra un nuevo usuario en la plataforma.
     * <p>
     * Todos los datos personales provienen del JWT de Firebase verificado
     * por el filtro de seguridad. El {@code courseId} es opcional y viene
     * del body de la petición (seleccionado en onboarding).
     * </p>
     *
     * <b>Reglas de negocio:</b>
     * <ul>
     *   <li><b>Validación crítica:</b> si el UID ya existe en la BD, lanza
     *       {@link IllegalArgumentException} → el controlador retorna 409.
     *       Esto permite que el frontend ejecute su flujo Upsert.</li>
     *   <li>Asigna valores por defecto gamificados:
     *       500 gemas, 5 corazones, 0 días de racha, 0 XP.</li>
     *   <li>Si {@code courseId} es nulo, asume {@code "course_en"}.</li>
     *   <li>Busca el {@link Course} en BD; si no existe, lanza excepción.</li>
     *   <li>Vincula el curso al usuario ({@code currentCourse}) y crea un
     *       registro de progreso inicial en {@code user_course_progress}
     *       con el primer nodo del curso como punto de partida.</li>
     * </ul>
     *
     * <h3>Atomicidad (ACID) con {@code @Transactional}</h3>
     * <p>
     * Las tres operaciones de escritura (guardar usuario, guardar progreso)
     * se ejecutan dentro de la misma transacción. Si cualquiera falla,
     * Spring ejecuta rollback automático, garantizando que nunca exista
     * un usuario en la BD sin su correspondiente registro de progreso.
     * </p>
     *
     * @param uid       UID de Firebase (del token verificado)
     * @param email     Email del usuario (del token)
     * @param name      Nombre visible (del token, default "Estudiante")
     * @param avatarUrl URL del avatar (del token, puede ser null)
     * @param courseId  ID del curso seleccionado (del body, opcional)
     * @return {@link UserProfileDTO} con los datos del usuario recién creado
     * @throws IllegalArgumentException si el UID ya está registrado
     * @throws NoSuchElementException   si el courseId no existe en la BD
     */
    @Transactional
    public UserProfileDTO register(String uid, String email, String name,
                                   String avatarUrl, String courseId) {
        // ── Validación de unicidad ──
        // Si el usuario ya existe, el frontend recibe 409 y ejecuta su flujo Upsert
        if (userRepository.existsById(uid)) {
            throw new IllegalArgumentException("El usuario con UID " + uid + " ya está registrado");
        }

        // ── Resolución del curso (default: course_en) ──
        String resolvedCourseId = courseId != null ? courseId : "course_en";
        Course course = courseRepository.findById(resolvedCourseId)
                .orElseThrow(() -> new NoSuchElementException(
                        "Curso no encontrado: " + resolvedCourseId));

        // ── Primer nodo del curso (para inicializar el progreso) ──
        LessonNode firstNode = lessonNodeRepository
                .findByCourseIdOrderByNodeIndexAsc(resolvedCourseId)
                .stream()
                .findFirst()
                .orElse(null);

        // ── Construcción y persistencia del usuario ──
        AppUser appUser = AppUser.builder()
                .id(uid)
                .email(email)
                .name(name)
                .avatarUrl(avatarUrl != null ? avatarUrl : "")
                .streakDays(0)
                .gems(500)
                .totalXp(0)
                .hearts(5)
                .currentCourse(course)
                .build();

        appUser = userRepository.save(appUser);

        // ── Creación del registro de progreso inicial ──
        UserCourseProgress progress = UserCourseProgress.builder()
                .user(appUser)
                .course(course)
                .currentLessonNode(firstNode)
                .build();

        progressRepository.save(progress);

        return toProfileDTO(appUser);
    }

    /**
     * Obtiene el perfil completo de un usuario por su UID.
     *
     * @param uid Identificador único de Firebase Auth
     * @return {@link UserProfileDTO} con todos los datos del perfil
     * @throws java.util.NoSuchElementException si el UID no existe
     */
    public UserProfileDTO getProfile(String uid) {
        AppUser appUser = userRepository.findById(uid)
                .orElseThrow(() -> new java.util.NoSuchElementException(
                        "Usuario no encontrado con UID: " + uid));

        return toProfileDTO(appUser);
    }

    /**
     * Verifica la existencia de un usuario y retorna su perfil si existe.
     *
     * @param uid Identificador único de Firebase Auth
     * @return {@link UserProfileDTO} si el usuario existe, {@code null} si no
     */
    public UserProfileDTO login(String uid) {
        return userRepository.findById(uid)
                .map(this::toProfileDTO)
                .orElse(null);
    }

    /**
     * Convierte una entidad {@link AppUser} en un {@link UserProfileDTO}.
     */
    private UserProfileDTO toProfileDTO(AppUser entity) {
        String courseId = entity.getCurrentCourse() != null
                ? entity.getCurrentCourse().getId()
                : null;

        return new UserProfileDTO(
                entity.getId(),
                entity.getEmail(),
                entity.getName(),
                entity.getAvatarUrl(),
                entity.getStreakDays(),
                entity.getGems(),
                entity.getTotalXp(),
                entity.getHearts(),
                courseId,
                entity.getCreatedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)
        );
    }
}
