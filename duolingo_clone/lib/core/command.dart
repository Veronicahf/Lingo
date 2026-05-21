import 'dart:async';

/// Contrato base para encapsular una acción ejecutable dentro de la arquitectura MVVM.
///
/// Los botones, gestos y otros disparadores de UI usarán implementaciones de esta clase
/// para desacoplar la vista de la lógica de negocio y mantener el principio de responsabilidad única.
abstract class Command<T> {
  /// Ejecuta la acción asociada al comando.
  T execute();
}
