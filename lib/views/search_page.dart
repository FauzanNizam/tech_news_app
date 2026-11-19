import 'package:flutter/material.dart';

import '../models/article_model.dart';
import '../services/news_service.dart';
import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  final String keyword;

  const SearchPage({super.key, required this.keyword});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final NewsService _newsService = NewsService();

  late Future<List<ArticleModel>> searchFuture;

  @override
  void initState() {
    super.initState();
    searchFuture = _newsService.searchNews(widget.keyword);
  }

  void retrySearch() {
    setState(() {
      searchFuture = _newsService.searchNews(widget.keyword);
    });
  }

  Future<void> refreshSearch() async {
    retrySearch();

    try {
      await searchFuture;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Hasil: ${widget.keyword}'),
        backgroundColor: const Color(0xFF14213D),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: refreshSearch,
        child: FutureBuilder<List<ArticleModel>>(
          future: searchFuture,
          builder: (context, snapshot) {
            // STATE 1: LOADING
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 250),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            // STATE 2: ERROR
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 150),
                  const Icon(Icons.error_outline, color: Colors.red, size: 65),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: retrySearch,
                      child: const Text('Coba Lagi'),
                    ),
                  ),
                ],
              );
            }

            final articles = snapshot.data ?? [];

            // STATE 3: EMPTY
            if (articles.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Icon(Icons.search_off, size: 65, color: Colors.grey),
                  SizedBox(height: 15),
                  Center(child: Text('Berita tidak ditemukan.')),
                ],
              );
            }

            // STATE 4: DATA
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(article: article),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.image.isNotEmpty)
                          Image.network(
                            article.image,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.prefer,
                            errorBuilder: (_, _, _) => Container(
                              height: 180,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image, size: 45),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(14),
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
                              const SizedBox(height: 8),
                              Text(
                                article.title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                article.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
