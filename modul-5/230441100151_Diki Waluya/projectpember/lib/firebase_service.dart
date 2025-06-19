import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());

  // Jalankan hanya sekali untuk seed data
  await seedData(); 
}

Future<void> seedData() async {
  final firestore = FirebaseFirestore.instance;

  await firestore.collection('makanan').doc('salad_sayur').set({
    'nama': 'Salad Sayur',
    'kategori': 'Makanan Sehat',
    'kalori': 120,
  });

  await firestore.collection('makanan').doc('ayam_panggang').set({
    'nama': 'Ayam Panggang',
    'kategori': 'Makanan Sehat',
    'kalori': 250,
  });

  await firestore.collection('makanan').doc('smoothie_buah').set({
    'nama': 'Smoothie Buah',
    'kategori': 'Minuman Sehat',
    'kalori': 180,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Seed Firestore')),
        body: Center(child: Text('Data Seeded')),
      ),
    );
  }
}
