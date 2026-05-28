import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/news_article.dart';
import '../repositories/news_repository.dart';

/// ViewModel responsable de cargar y exponer los articulos de novedades.
///
/// Esta clase desacopla la vista del origen de datos y mantiene el estado de carga mientras
/// obtiene el feed desde el repositorio mock o, en el futuro, desde la API.
class NewsViewModel extends BaseViewModel {
  /// Crea la ViewModel de novedades con repositorio opcional inyectado.
  ///
  /// Si no se proporciona uno, se usa la instancia registrada en [ServiceLocator].
  NewsViewModel({MockNewsRepository? newsRepository})
      : _newsRepository = newsRepository ?? ServiceLocator.newsRepository;

  final MockNewsRepository _newsRepository;

  List<NewsArticle> _articles = const [];

  /// Articulos de novedades disponibles para pintar en la vista.
  List<NewsArticle> get articles => _articles;

  /// Alterna el like de una publicacion y recarga el feed local para notificar cambios.
  Future<void> toggleLike(String postId) async {
    try {
      await _newsRepository.toggleLike(postId);
      _articles = await _newsRepository.getNewsArticles();
      notifyListeners();
    } catch (_) {
      setError('No se pudo actualizar la novedad.');
    }
  }

  // TODO: Consumir API de Spring Boot cuando el backend de novedades este disponible.
  /// Carga los articulos de novedades y notifica a la UI una vez listos.
  Future<void> loadNewsArticles() async {
    setLoading(true);

    try {
      _articles = await _newsRepository.getNewsArticles();
      setSuccess();
    } catch (error) {
      setError('No se pudieron cargar las novedades.');
    }
  }
}