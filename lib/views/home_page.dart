import 'package:flutter/material.dart';

import '../models/article_model.dart';
import '../services/news_service.dart';
import 'detail_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsService _newsService = NewsService();

  final List<String> categories = [
    'Teknologi',
    'AI',
    'Gadget',
    'Gaming',
    'Startup',
  ];

  String selectedCategory = 'Teknologi';

  // Cache Future berdasarkan kategori
  final Map<String, Future<List<ArticleModel>>> categoryCache = {};

  late Future<List<ArticleModel>> newsFuture;

  @override
  void initState() {
    super.initState();
    newsFuture = getCategoryNews(selectedCategory);
  }

  // Mengambil berita dan menyimpan Future ke cache
  Future<List<ArticleModel>> getCategoryNews(String category) {
    if (!categoryCache.containsKey(category)) {
      categoryCache[category] = _newsService.fetchNews(category);
    }

    return categoryCache[category]!;
  }

  // Mengganti kategori
  void changeCategory(String category) {
    setState(() {
      selectedCategory = category;
      newsFuture = getCategoryNews(category);
    });
  }

  // Refresh berita
  Future<void> refreshNews() async {
    setState(() {
      categoryCache.remove(selectedCategory);
      newsFuture = getCategoryNews(selectedCategory);
    });

    try {
      await newsFuture;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  // Coba lagi jika terjadi error
  void retryNews() {
    setState(() {
      categoryCache.remove(selectedCategory);
      newsFuture = getCategoryNews(selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        toolbarHeight: 65,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.newspaper, size: 27),
            SizedBox(width: 10),
            Text(
              'TechNews',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF14213D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final controller = TextEditingController();

                  return AlertDialog(
                    title: const Text('Cari Berita'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan kata kunci...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) {
                        final keyword = value.trim();
                        if (keyword.isNotEmpty) {
                          Navigator.pop(context);
                          Navigator.push(
                            this.context,
                            MaterialPageRoute(
                              builder: (_) => SearchPage(keyword: keyword),
                            ),
                          );
                        }
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final keyword = controller.text.trim();

                          if (keyword.isNotEmpty) {
                            Navigator.pop(context);
                            Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                builder: (_) => SearchPage(keyword: keyword),
                              ),
                            );
                          }
                        },
                        child: const Text('Cari'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF14213D),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Berita Teknologi Terkini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Informasi teknologi Indonesia untukmu.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: Text(
              'Kategori Berita',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: categories.map((category) {
                final selected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    selectedColor: const Color(0xFF14213D),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                    ),
                    onSelected: (_) => changeCategory(category),
                  ),
                );
              }).toList(),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Berita Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshNews,
              child: FutureBuilder<List<ArticleModel>>(
                future: newsFuture,
                builder: (context, snapshot) {
                  // STATE 1: LOADING
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // STATE 2: ERROR
                  if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 100),
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: retryNews,
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
                        SizedBox(height: 100),
                        Icon(
                          Icons.article_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Center(child: Text('Tidak ada berita ditemukan.')),
                      ],
                    );
                  }

                  // STATE 4: DATA
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];

                      print('JUDUL: ${article.title}');
                      print('IMAGE: ${article.image}');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
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
                                  height: 190,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  webHtmlElementStrategy:
                                      WebHtmlElementStrategy.prefer,
                                  errorBuilder: (_, _, _) => Container(
                                    height: 190,
                                    width: double.infinity,
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
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
          ),
        ],
      ),
    );
  }
}
