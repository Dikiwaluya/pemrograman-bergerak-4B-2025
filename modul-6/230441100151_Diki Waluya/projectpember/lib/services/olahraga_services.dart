import 'package:firebase_database/firebase_database.dart';
import '../models/olahraga_model.dart';

class OlahragaService {
  final _dbRef = FirebaseDatabase.instance.ref('rekomendasi_olahraga');

Future<List<Olahraga>> fetchOlahragaList() async {
  final snapshot = await _dbRef.get();

  if (snapshot.exists) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);

    return data.values
        .map((e) => Olahraga.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  } else {
    return [];
  }
}
}
