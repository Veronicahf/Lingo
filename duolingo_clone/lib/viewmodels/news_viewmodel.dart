import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/news_article.dart';
import '../repositories/user_repository.dart';

/// ViewModel responsable de cargar y exponer los articulos de novedades.
///
/// Esta clase desacopla la vista del origen de datos y mantiene el estado de carga mientras
/// obtiene el feed desde el repositorio mock o, en el futuro, desde la API.
class NewsViewModel extends BaseViewModel {
  /// Crea la ViewModel de novedades con repositorio opcional inyectado.
  ///
  /// Si no se proporciona uno, se usa la instancia registrada en [ServiceLocator].
  NewsViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockUserRepository _userRepository;

  List<NewsArticle> _articles = const [];

  /// Articulos de novedades disponibles para pintar en la vista.
  List<NewsArticle> get articles => _articles;

  // TODO: Consumir API de Spring Boot cuando el backend de novedades este disponible.
  /// Carga los articulos de novedades y notifica a la UI una vez listos.
  Future<void> loadNewsArticles() async {
    setLoading(true);

    try {
      _articles = await _userRepository.getNewsArticles();
      setSuccess();
    } catch (error) {
      setError('No se pudieron cargar las novedades.');
    }
  }
}