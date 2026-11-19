class ArticleModel {
  final String title;
  final String description;
  final String content;
  final String image;
  final String url;
  final String publishedAt;
  final String source;

  ArticleModel({
    required this.title,
    required this.description,
    required this.content,
    required this.image,
    required this.url,
    required this.publishedAt,
    required this.source,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      image: json['image'] ?? '',
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      source: json['source']?['name'] ?? 'Unknown',
    );
  }
}
