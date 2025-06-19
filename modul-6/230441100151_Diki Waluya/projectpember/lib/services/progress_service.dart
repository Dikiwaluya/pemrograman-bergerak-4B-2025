import 'dart:convert';
import 'package:http/http.dart' as http;

class ProgressService {
  final String baseUrl = "http://192.168.1.11/api_aplikasi_weight_tracker";

  Future<List<Map<String, dynamic>>> fetchProgress(String uid) async {
    final response = await http.post(
      Uri.parse("$baseUrl/get_progress.php"),
      body: {'firebase_uid': uid},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }
    throw Exception('Gagal ambil data progress');
  }

  Future<bool> saveProgress({
    required String uid,
    required double berat,
    required double tinggi,
    double? target,
  }) async {
    final body = {
      'firebase_uid': uid,
      'berat': berat.toString(),
      'tinggi': tinggi.toString(),
      'tanggal': DateTime.now().toIso8601String(),
    };

    if (target != null) {
      body['target_berat'] = target.toString();
    }

    final response = await http.post(
      Uri.parse("$baseUrl/insert_progress.php"),
      body: body,
    );

    final data = json.decode(response.body);
    print("🛰️ Response from Server: ${response.body}");

    return data['status'] == 'inserted' || data['status'] == 'updated';
  }

  Future<bool> deleteProgress(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_progress.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      final json = jsonDecode(response.body);
      return json['success'] == true;
    } catch (e) {
      print('❌ Error saat menghapus progress: $e');
      return false;
    }
  }
}
