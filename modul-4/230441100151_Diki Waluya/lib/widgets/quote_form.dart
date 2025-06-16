import 'package:flutter/material.dart';

class QuoteForm extends StatelessWidget {
  final TextEditingController authorController;
  final TextEditingController quoteController;
  final VoidCallback onSave;

  QuoteForm({
    required this.authorController,
    required this.quoteController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: authorController,
            decoration: InputDecoration(
              labelText: 'Penulis',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: quoteController,
            decoration: InputDecoration(
              labelText: 'Isi Quote',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
