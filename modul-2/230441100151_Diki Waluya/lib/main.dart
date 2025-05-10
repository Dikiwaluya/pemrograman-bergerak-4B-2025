import 'package:flutter/material.dart';
import 'home_screen.dart'; // pastikan import ini ada

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // biar gak ada banner debug
      title: 'Travel App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(), // arahkan ke HomeScreen
    );
  }
}
