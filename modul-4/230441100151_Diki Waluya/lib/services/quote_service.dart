import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';
import 'package:uuid/uuid.dart';

class QuoteServiceHttp {
  final String baseUrl =
      'https://quoteharian-eaab5-default-rtdb.firebaseio.com/quoteharian';

  // Ambil semua quote
  Future<List<QuoteModel>> getQuotes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl.json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>?;

        if (data == null) return [];

        return data.entries.map((entry) {
          final quote = QuoteModel.fromMap(entry.value);
          quote.id = entry.key;
          return quote;
        }).toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat mengambil data: $e');
      rethrow;
    }
  }

  // Tambah quote baru
  Future<void> addQuote(QuoteModel quote) async {
    try {
      final id = const Uuid().v4();
      quote.id = id;

      final response = await http.put(
        Uri.parse('$baseUrl/$id.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(quote.toMap()),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menambahkan quote: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat menambahkan quote: $e');
      rethrow;
    }
  }

  // Update quote yang sudah ada
  Future<void> updateQuote(QuoteModel quote) async {
    try {
      if (quote.id == null) {
        throw Exception('ID quote tidak tersedia');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/${quote.id}.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(quote.toMap()),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengupdate quote: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat update quote: $e');
      rethrow;
    }
  }

  // Hapus quote berdasarkan ID
  Future<void> deleteQuote(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id.json'));

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus quote: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat hapus quote: $e');
      rethrow;
    }
  }
}
