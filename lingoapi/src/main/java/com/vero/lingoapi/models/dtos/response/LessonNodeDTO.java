package com.vero.lingoapi.models.dtos.response;

/**
 * DTO que representa un nodo del mapa de lecciones (camino de aprendizaje).
 * <p>
 * El frontend usa estos datos para renderizar el mapa SVG: cada nodo
 * es un círculo en una posición ({@code coordinates}) con un título
 * y un orden secuencial ({@code nodeIndex}) que determina las flechas
 * de conexión entre nodos.
 * </p>
 *
 * @param id          Identificador único del nodo (ej. "node_en_1")
 * @param title       Título visible de la lección
 * @param nodeIndex   Posición ordinal en el mapa (1, 2, 3…)
 * @param coordinates Coordenadas "x,y" para posicionar el círculo en la UI
 */
public record LessonNodeDTO(
        String id,
        String title,
        Integer nodeIndex,
        String coordinates
) {
}
