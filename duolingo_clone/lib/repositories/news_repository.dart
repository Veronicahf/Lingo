import 'package:flutter/material.dart';

import '../core/mock_database.dart';
import '../models/news_article.dart';

// TODO: Conectar a API Spring Boot real.
/// Repositorio mock encargado del feed social de novedades.
class MockNewsRepository {
  /// Crea un repositorio de noticias respaldado por la base en memoria.
  const MockNewsRepository();

  /// Obtiene el feed social como publicaciones de dominio puras.
  Future<List<NewsPost>> getNewsFeed() async {
    return List<NewsPost>.unmodifiable(MockDatabase.instance.newsFeed);
  }

  /// Obtiene el feed social convertido al modelo que consume la UI actual.
  Future<List<NewsArticle>> getNewsArticles() async {
    final posts = await getNewsFeed();
    return List<NewsArticle>.generate(posts.length, (index) {
      final post = posts[index];
      return _mapPostToArticle(post, index);
    }, growable: false);
  }

  /// Alterna el like de una publicacion en la base de datos en memoria.
  Future<void> toggleLike(String postId) async {
    MockDatabase.instance.toggleLikeNewsPost(postId);
  }

  NewsArticle _mapPostToArticle(NewsPost post, int index) {
    final Color backgroundColor = _backgroundColorForIndex(index);
    final IconData iconData = _iconForIndex(index);
    final String title = _buildTitle(post);
    final String description = _buildDescription(post);
    final String buttonText = post.isLikedByMe ? 'TE GUSTA' : 'ME GUSTA';

    return NewsArticle(
      id: post.id,
      title: title,
      description: description,
      buttonText: buttonText,
      backgroundColor: backgroundColor.value,
      iconData: iconData,
      likesCount: post.likesCount,
      isLikedByMe: post.isLikedByMe,
    );
  }

  String _buildTitle(NewsPost post) {
    final String content = post.content.trim();

    if (content.length <= 52) {
      return content;
    }

    return '${content.substring(0, 49)}...';
  }

  String _buildDescription(NewsPost post) {
    final String likeLabel = post.likesCount == 1 ? '1 like' : '${post.likesCount} likes';
    final String likedLabel = post.isLikedByMe ? 'Tu ya reaccionaste a esta publicacion.' : 'Pulsa para reaccionar a esta publicacion.';
    return '${post.authorName} · $likeLabel · $likedLabel';
  }

  Color _backgroundColorForIndex(int index) {
    const palette = <Color>[
      Color(0xFF24A0E0),
      Color(0xFF26333B),
      Color(0xFF9FE33A),
      Color(0xFF3D8BFF),
    ];
    return palette[index % palette.length];
  }

  IconData _iconForIndex(int index) {
    const icons = <IconData>[
      Icons.celebration_rounded,
      Icons.local_fire_department_rounded,
      Icons.flutter_dash_rounded,
      Icons.groups_rounded,
    ];
    return icons[index % icons.length];
  }
}