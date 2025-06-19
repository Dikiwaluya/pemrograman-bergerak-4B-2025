import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:projectpember/services/progress_service.dart';
import 'package:projectpember/models/weight_entry.dart';
import 'package:projectpember/screens/food_list_screen.dart';
import 'package:projectpember/screens/olahraga_screen.dart';
import 'package:projectpember/pages/profile_page.dart';

class HomeScreen extends StatefulWidget {
  final String firebaseUid;
  const HomeScreen({super.key, required this.firebaseUid});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  List<WeightEntry> _progressData = [];
  double? _initialWeight;
  double? _targetWeight;
  double? _currentHeight;

  final _beratController = TextEditingController();
  final _tinggiController = TextEditingController();
  final _targetController = TextEditingController();

  final ProgressService _progressService = ProgressService();

  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    try {
      final raw = await _progressService.fetchProgress(widget.firebaseUid);
      final parsed = raw.map((e) => WeightEntry.fromJson(e)).toList();

      setState(() {
        _progressData = parsed;
        _isLoading = false;

        if (_progressData.isNotEmpty) {
          final first = _progressData.first;
          final last = _progressData.last;
          _initialWeight = first.weight;
          _targetWeight = first.targetWeight;
          _currentHeight = last.height;

          final bool goalReached = _targetWeight != null &&
              (last.weight - _targetWeight!).abs() <= 0.2;

          if (goalReached) _showCongratsDialog();
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Error: $e");
    }
  }

  Future<void> _saveProgress() async {
    final berat = double.tryParse(_beratController.text);
    final tinggi = double.tryParse(_tinggiController.text);
    final target = _targetWeight ?? double.tryParse(_targetController.text);

    if (berat != null && tinggi != null && target != null) {
      final success = await _progressService.saveProgress(
        uid: widget.firebaseUid,
        berat: berat,
        tinggi: tinggi,
        target: _targetWeight == null ? target : null,
      );

      if (success) {
        _beratController.clear();
        _tinggiController.clear();
        _targetController.clear();
        await _fetchProgress();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Progress berhasil disimpan.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi semua kolom dengan benar.")),
      );
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Progress?"),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _progressService.deleteProgress(id);
              if (success) await _fetchProgress();
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCongratsDialog() {
    showDialog(
      context: context,
      barrierColor: const Color.fromARGB(174, 0, 0, 0),
      barrierDismissible: false,
      builder: (context) => Center(
        child: Lottie.asset("assets/animation/selamat.json", height: 200, repeat: false),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Navigator.canPop(context)) Navigator.pop(context);
    });
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildInitialForm() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1D2B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Masukkan Data Awal",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTextField("Berat Awal (kg)", _beratController),
            _buildTextField("Tinggi Badan (cm)", _tinggiController),
            _buildTextField("Target Berat (kg)", _targetController),
            ElevatedButton(
              onPressed: _saveProgress,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              child: const Text("Simpan & Mulai"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateForm() {
    return Container(
      color: const Color(0xFF1F1D2B),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Target Berat: ${_targetWeight?.toStringAsFixed(1)} kg", style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          _buildTextField("Update Berat (kg)", _beratController),
          _buildTextField("Tinggi Badan (cm)", _tinggiController),
          Center(
            child: ElevatedButton(
              onPressed: _saveProgress,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
              child: const Text("Update Progress"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    final last = _progressData.last;
    final double sisa = (_targetWeight! - last.weight).abs();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1D2B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ringkasan Progress",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn("Berat", "${last.weight.toStringAsFixed(1)} kg"),
                _buildInfoColumn("Target", "${_targetWeight!.toStringAsFixed(1)} kg"),
                _buildInfoColumn("Sisa", "${sisa.toStringAsFixed(1)} kg"),
                _buildInfoColumn("Tinggi", "${last.height.toStringAsFixed(1)} cm"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRiwayat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text("Riwayat Progress", style: TextStyle(color: Colors.white70, fontSize: 16)),
        ),
        ..._progressData.reversed.map((entry) {
          final sisa = (_targetWeight! - entry.weight).abs();
          final tanggal = DateFormat('dd MMMM yyyy').format(entry.createdAt.toLocal());

          return Card(
            color: const Color(0xFF1F1D2B),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              title: Text("Berat: ${entry.weight} kg | Tinggi: ${entry.height} cm", style: const TextStyle(color: Colors.white)),
              subtitle: Text("Sisa: ${sisa.toStringAsFixed(1)} kg\nTanggal: $tanggal",
                  style: const TextStyle(color: Colors.white54)),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _confirmDelete(entry.id!),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProgressPage() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_progressData.isEmpty) return _buildInitialForm();

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 40, bottom: 20),
          child: Center(
            child: Text("Your Progress", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ),
        _buildUpdateForm(),
        const SizedBox(height: 10),
        Center(child: Lottie.asset("assets/animation/gym_animation.json", height: 260)),
        _buildRiwayat(),
        _buildProgressSummary(),
        const SizedBox(height: 80),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildProgressPage(),
      FoodListScreen(firebaseUid: widget.firebaseUid),
      const JadwalScreen(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0C1D),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: const Color(0xFFFCD581),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.monitor_weight), label: 'Progres'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Makanan'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Olahraga'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
