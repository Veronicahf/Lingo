package com.vero.lingoapi.repositories;

import com.vero.lingoapi.models.entities.AppUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio Spring Data JPA para la entidad {@link AppUser}.
 * <p>
 * Proporciona operaciones CRUD básicas (findById, save, delete, etc.)
 * sin necesidad de implementación manual.
 * </p>
 * <p>
 * El tipo del ID es {@link String} porque la clave primaria es el UID
 * de Firebase Auth. Esta decisión evita:
 * <ul>
 *   <li>Mantener una tabla o columna adicional de mapeo UID-ID</li>
 *   <li>Inconsistencias entre el identificador de Firebase y el interno</li>
 *   <li>Traducciones innecesarias en cada request (el frontend ya opera con UIDs)</li>
 * </ul>
 * </p>
 */
@Repository
public interface UserRepository extends JpaRepository<AppUser, String> {

    /**
     * Verifica si existe un usuario con el UID de Firebase dado.
     * <p>
     * Equivalente SQL: {@code SELECT COUNT(*) > 0 FROM app_users WHERE id = :uid}
     * </p>
     *
     * @param uid Identificador único de Firebase
     * @return {@code true} si el usuario existe en la base de datos
     */
    boolean existsById(String uid);
}
