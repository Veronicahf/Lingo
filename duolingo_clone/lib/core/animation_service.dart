/// Servicio centralizado que resuelve rutas de assets Lottie a partir de emociones.
///
/// Elimina el hardcoding de rutas en los widgets y centraliza el mapeo
/// emocion -> archivo JSON para facilitar mantenimiento y reutilizacion.
class AnimationService {
  AnimationService._();

  static final AnimationService instance = AnimationService._();

  static const Map<String, String> _emotionToAsset = <String, String>{
    'happy': 'assets/lottie/cat_happy.json',
    'speaking': 'assets/lottie/Cat_typing.json',
    'typing': 'assets/lottie/Cat_typing.json',
    'sad': 'assets/lottie/cat_sad.json',
    'sleeping': 'assets/lottie/cat_sleeping.json',
    'rocket': 'assets/lottie/Cat_in_a_rocket.json',
    'loading': 'assets/lottie/Loading_Cat.json',
    'idle': 'assets/lottie/cat_idle.json',
  };

  /// Retorna la ruta del asset Lottie correspondiente a la emocion indicada.
  ///
  /// Si [emotion] no existe en el mapa, retorna 'assets/lottie/cat_idle.json'
  /// como valor por defecto.
  String getAssetForEmotion(String emotion) {
    return _emotionToAsset[emotion.trim().toLowerCase()] ?? 'assets/lottie/cat_idle.json';
  }
}
