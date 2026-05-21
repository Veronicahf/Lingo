import 'package:flutter/foundation.dart';

/// Clase base para todas las ViewModels del proyecto.
///
/// Centraliza el estado común de la capa de presentación, incluyendo carga, éxito y error,
/// para que cada ViewModel concreta herede comportamiento consistente y notifique cambios a la UI.
class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  /// Indica si la ViewModel está realizando una operación asíncrona.
  bool get isLoading => _isLoading;

  /// Indica si la última operación terminó correctamente.
  bool get isSuccess => _isSuccess;

  /// Mensaje de error de la última operación, si existe.
  String? get errorMessage => _errorMessage;

  /// Marca la ViewModel como cargando y notifica a la UI.
  void setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _isSuccess = false;
      _errorMessage = null;
    }
    notifyListeners();
  }

  /// Marca la ViewModel como exitosa y notifica a la UI.
  void setSuccess() {
    _isLoading = false;
    _isSuccess = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Marca la ViewModel como fallida y almacena el mensaje de error.
  void setError(String message) {
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = message;
    notifyListeners();
  }

  /// Limpia el estado interno para reutilizar la ViewModel en un flujo nuevo.
  void resetState() {
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = null;
    notifyListeners();
  }
}
