import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'du0lvrui2';
  static const String uploadPreset = 'unisigned_tracker';
  static const String folderName = 'tracker/';

  static Future<String> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = uploadPreset
            ..fields['folder'] = folderName
            ..files.add(
              await http.MultipartFile.fromPath('file', imageFile.path),
            );

      // Tambahkan timeout untuk menghindari loading tak selesai
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Validasi URL dari Cloudinary
        if (data['secure_url'] == null) {
          throw Exception('Upload berhasil tapi secure_url tidak ditemukan.');
        }

        print('Upload berhasil: ${data['secure_url']}');
        return data['secure_url'];
      } else {
        print('Upload gagal: ${response.body}');
        throw Exception('Upload gagal ke Cloudinary: ${response.body}');
      }
    } catch (e) {
      print('error saat upload ke Cloudinary: $e');
      rethrow;
    }
  }
}
