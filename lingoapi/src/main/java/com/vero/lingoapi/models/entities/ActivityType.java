package com.vero.lingoapi.models.entities;

/**
 * Enum que tipifica los formatos de actividad que el frontend
 * puede renderizar dentro de una lección.
 * <p>
 * Cada constante representa un tipo de interacción distinta con
 * su propia estructura de datos interna (payload): opciones de
 * respuesta, audio, imágenes, etc. El valor se almacena como
 * String en la BD ({@code @Enumerated(EnumType.STRING)}) para
 * que sea legible y no se rompa si se reordenan las constantes.
 * </p>
 *
 * <ul>
 *   <li>{@link #translateSentence} — el usuario escribe la traducción</li>
 *   <li>{@link #listenSelect} — el usuario escucha y selecciona</li>
 *   <li>{@link #fillBlank} — completar el espacio en blanco</li>
 *   <li>{@link #speaking} — actividad de pronunciación</li>
 *   <li>{@link #selectTranslation} — seleccionar entre opciones</li>
 *   <li>{@link #unknown} — tipo no definido (fallback)</li>
 * </ul>
 */
public enum ActivityType {
    translateSentence,
    listenSelect,
    fillBlank,
    speaking,
    selectTranslation,
    unknown
}
