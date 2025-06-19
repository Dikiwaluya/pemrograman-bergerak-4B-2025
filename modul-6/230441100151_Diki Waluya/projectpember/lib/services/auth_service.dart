import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String mysqlApiUrl =
      'http://192.168.1.11/api_aplikasi_weight_tracker/register_user.php';

  /// Login useri
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _firebaseErrorMessage(e);
    } catch (_) {
      return 'Terjadi kesalahan tak terduga saat login.';
    }
  }

  /// Register user ke Firebase Auth, Firestore, dan MySQL
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;
      if (user == null) return 'User tidak ditemukan setelah registrasi.';

      // Simpan ke Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Simpan ke MySQL
      final response = await http.post(
        Uri.parse(mysqlApiUrl),
        body: {'uid': user.uid, 'email': email, 'name': name},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] != 'success') {
          return 'Gagal simpan ke MySQL: ${body['message']}';
        }
      } else {
        return 'Gagal koneksi ke server MySQL. Status code: ${response.statusCode}';
      }

      return null; // sukses
    } on FirebaseAuthException catch (e) {
      return _firebaseErrorMessage(e);
    } catch (e) {
      return 'Terjadi kesalahan saat registrasi: ${e.toString()}';
    }
  }

  /// Ambil user yang sedang login
  User? getCurrentUser() => _auth.currentUser;

  /// Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Konversi error FirebaseAuth ke pesan readable
  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah digunakan.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'user-not-found':
        return 'User tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      default:
        return 'Auth error: ${e.message}';
    }
  }
}
