import 'package:flutter/material.dart';

import '../models/article_model.dart';

import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatelessWidget {
  final ArticleModel article;

  const DetailPage({super.key, required this.article});

  Future<void> _openArticle() async {
    final uri = Uri.tryParse(article.url);

    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detail Berita'),
        backgroundColor: const Color(0xFF14213D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.image.isNotEmpty)
              Image.network(
                article.image,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (_, _, _) => Container(
                  height: 250,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 60),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.source,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    article.publishedAt,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const Divider(height: 30),

                  Text(
                    article.description,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    article.content.isNotEmpty
                        ? article.content
                        : article.description,
                    style: const TextStyle(fontSize: 15, height: 1.7),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openArticle,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Baca Artikel Lengkap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14213D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
