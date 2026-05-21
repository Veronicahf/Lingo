import 'package:flutter/material.dart';

import '../../models/news_article.dart';
import '../../viewmodels/news_viewmodel.dart';

/// Pantalla de novedades que presenta noticias, promociones y contenido social desde datos.
///
/// Esta vista escucha al [NewsViewModel] y dibuja sus tarjetas iterando sobre una lista de
/// [NewsArticle], evitando el contenido escrito directamente en la UI.
class NewsView extends StatefulWidget {
  /// Crea la pantalla de novedades.
  const NewsView({super.key});

  @override
  State<NewsView> createState() => _NewsViewState();
}

/// Estado interno de [NewsView] que carga y libera el ViewModel.
class _NewsViewState extends State<NewsView> {
  late final NewsViewModel _viewModel = NewsViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadNewsArticles();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          const Text(
            'Novedades',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 26),
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              final articles = _viewModel.articles;

              if (articles.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return Column(
                children: [
                  for (var index = 0; index < articles.length; index++) ...[
                    _NewsArticleCard(article: articles[index]),
                    if (index != articles.length - 1) ...[
                      const SizedBox(height: 22),
                      const Divider(color: Color(0xFF2B3840), height: 1),
                      const SizedBox(height: 18),
                    ],
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de novedad reutilizable construida a partir de [NewsArticle].
class _NewsArticleCard extends StatelessWidget {
  /// Crea una tarjeta de novedad basada en el modelo.
  const _NewsArticleCard({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    if (article.id == 'news_01') {
      return _NewsPromoCard(article: article);
    }

    if (article.id == 'news_03') {
      return _NewsQuoteCard(article: article);
    }

    return _NewsFeedItem(article: article);
  }
}

/// Tarjeta promocional superior de novedades.
class _NewsPromoCard extends StatelessWidget {
  /// Crea la tarjeta promocional.
  const _NewsPromoCard({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Color(article.backgroundColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220,
            child: Text(
              article.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  offset: const Offset(0, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              article.buttonText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(article.backgroundColor),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Elemento de feed intermedio reutilizable en la pantalla de novedades.
class _NewsFeedItem extends StatelessWidget {
  /// Crea un item del feed a partir del modelo.
  const _NewsFeedItem({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF2C3A43),
          child: Text(
            article.title.isNotEmpty ? article.title[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'veronica',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '1 m',
                style: TextStyle(
                  color: Color(0xFF86939D),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                article.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  _SmallActionChip(
                    icon: Icons.favorite_border_rounded,
                    label: '0',
                  ),
                  SizedBox(width: 12),
                  _SmallActionChip(
                    icon: Icons.ios_share_rounded,
                    label: '',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: Color(article.backgroundColor),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Icon(article.iconData, color: Colors.white, size: 48),
        ),
      ],
    );
  }
}

/// Tarjeta de cita visual para una novedad destacada.
class _NewsQuoteCard extends StatelessWidget {
  /// Crea una tarjeta de cita usando el articulo recibido.
  const _NewsQuoteCard({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              color: Color(article.backgroundColor),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  article.description,
                  style: const TextStyle(
                    color: Color(0xFF8F9DA7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 82,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFF9FE33A),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(article.iconData, color: const Color(0xFF0E1C24), size: 60),
        ),
      ],
    );
  }
}

/// Boton compacto reutilizable de las tarjetas de novedades.
class _SmallActionChip extends StatelessWidget {
  /// Crea un chip con icono y etiqueta opcional.
  const _SmallActionChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: label.isEmpty ? 54 : 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A4952), width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}
