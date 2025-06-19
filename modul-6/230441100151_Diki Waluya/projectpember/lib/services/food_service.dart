import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class FoodService {
  static const String baseUrl =
      'http://192.168.1.11/api_aplikasi_weight_tracker/makanan';

  /// CREATE
  static Future<bool> createFood(FoodItem item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firebase_uid': item.firebaseUid,
        'nama_makanan': item.name,
        'description': item.description,
        'kalori': item.kalori,
        'jumlah': item.jumlah,
        'foto_url': item.imageUrl,
      }),
    );

    final result = jsonDecode(response.body);
    return result['status'] == 'success';
  }

  /// READ
  static Future<List<FoodItem>> getFoodsByUser(String firebaseUid) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/read.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'firebase_uid': firebaseUid},
      );

      print("READ Response: ${response.statusCode} - ${response.body}");

      final res = jsonDecode(response.body);

      if (res['status'] == 'success') {
        final data = res['data'];
        if (data == null || data.isEmpty) return [];
        return List<FoodItem>.from(data.map((x) => FoodItem.fromJson(x)));
      } else {
        throw Exception('Status gagal dari server: ${res['message']}');
      }
    } catch (e) {
      print("READ Error: $e");
      throw Exception("Gagal mengambil data: $e");
    }
  }

  /// UPDATE
  static Future<bool> updateFood(FoodItem food) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': food.id,
          'firebase_uid': food.firebaseUid,
          'nama_makanan': food.name,
          'description': food.description,
          'kalori': food.kalori,
          'jumlah': food.jumlah,
          'tanggal': food.tanggal,
          'foto_url': food.imageUrl,
        }),
      );

      print("UPDATE Response: ${response.statusCode} - ${response.body}");

      final result = jsonDecode(response.body);
      return result['status'] == 'success';
    } catch (e) {
      print("UPDATE Error: $e");
      return false;
    }
  }

  /// DELETE
  static Future<bool> deleteFood(int id, String firebaseUid) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'firebase_uid': firebaseUid}),
      );

      print("DELETE Response: ${response.statusCode} - ${response.body}");

      final res = jsonDecode(response.body);
      return res['status'] == 'success';
    } catch (e) {
      print("DELETE Error: $e");
      return false;
    }
  }
}
