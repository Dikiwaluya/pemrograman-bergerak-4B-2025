import 'package:flutter/material.dart';

class ProgressSummaryWidget extends StatelessWidget {
  final double berat;
  final double tinggi;
  final double target;
  final VoidCallback onUpdateTap;

  const ProgressSummaryWidget({
    super.key,
    required this.berat,
    required this.tinggi,
    required this.target,
    required this.onUpdateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ringkasan Journey",
              style: TextStyle(color: Color(0xFFFCD581), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Berat Saat Ini: ${berat.toStringAsFixed(1)} kg", style: const TextStyle(color: Colors.white)),
            Text("Tinggi Badan: ${tinggi.toStringAsFixed(1)} cm", style: const TextStyle(color: Colors.white)),
            Text("Target Berat: ${target.toStringAsFixed(1)} kg", style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: onUpdateTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFCD581),
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.edit),
              label: const Text("Update Journey"),
            ),
          ],
        ),
      ),
    );
  }
}
