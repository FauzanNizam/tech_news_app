import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article_model.dart';
import 'api_exception.dart';

class NewsService {
  static const String _baseUrl = 'https://gnews.io/api/v4';

  static const String _apiKey = String.fromEnvironment('GNEWS_API_KEY');

  Future<List<ArticleModel>> fetchNews(String keyword) async {
    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'q': keyword,
        'lang': 'id',
        'country': 'id',
        'max': '10',
        'apikey': _apiKey,
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['articles'] == null) {
          throw ApiException('Format data berita tidak valid.');
        }

        final List articles = data['articles'];

        return articles.map((item) => ArticleModel.fromJson(item)).toList();
      }

      switch (response.statusCode) {
        case 400:
          throw ApiException(
            'Permintaan tidak valid. Periksa API Key atau kata kunci pencarian.',
          );

        case 401:
          throw ApiException('API Key tidak valid atau tidak terdaftar.');

        case 403:
          throw ApiException(
            'Akses ditolak. Email belum diverifikasi atau kuota harian habis.',
          );

        case 404:
          throw ApiException('Endpoint API tidak ditemukan.');

        case 429:
          throw ApiException(
            'Batas penggunaan API telah tercapai. Coba beberapa saat lagi.',
          );

        default:
          if (response.statusCode >= 500) {
            throw ApiException(
              'Server GNews sedang bermasalah. Silakan coba lagi.',
            );
          }

          throw ApiException('Terjadi kesalahan HTTP: ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw ApiException(
        'Gagal terhubung ke server. Periksa koneksi internet.',
      );
    } on FormatException {
      throw ApiException('Format respons dari server tidak valid.');
    } on Exception {
      throw ApiException('Terjadi kesalahan saat mengambil berita.');
    }
  }

  Future<List<ArticleModel>> searchNews(String keyword) {
    return fetchNews(keyword);
  }
}
