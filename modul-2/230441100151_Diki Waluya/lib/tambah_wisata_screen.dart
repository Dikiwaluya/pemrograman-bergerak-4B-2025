import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TambahWisataPage extends StatefulWidget {
  const TambahWisataPage({super.key});

  @override
  State<TambahWisataPage> createState() => _TambahWisataPageState();
}

class _TambahWisataPageState extends State<TambahWisataPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  String? _jenisWisata;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _lokasiController.clear();
    _hargaController.clear();
    _deskripsiController.clear();
    setState(() {
      _jenisWisata = null;
      _image = null;
    });
  }

  bool _isNumeric(String str) => double.tryParse(str) != null;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  bool _isOnlyLetters(String str) {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Tambah Wisata',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Upload Gambar
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 38, 94, 224),
                      width: 2,
                    ),
                  ),
                  child:
                      _image == null
                          ? const Center(
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 60,
                              color: Colors.orange,
                            ),
                          )
                          : Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _pickImage,
                child: const Text(
                  "Upload Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nama Wisata
              _buildTextField(
                "Nama Wisata",
                "Masukkan Nama Wisata Disini",
                _namaController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  } else if (!_isOnlyLetters(value)) {
                    return 'Nama hanya boleh huruf';
                  }
                  return null;
                },
              ),

              // Lokasi Wisata
              _buildTextField(
                "Lokasi Wisata",
                "Masukkan Lokasi Wisata Disini",
                _lokasiController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi tidak boleh kosong';
                  }
                  return null;
                },
              ),

              // Jenis Wisata Dropdown
              _buildDropdownField(),

              // Harga Tiket
              _buildTextField(
                "Harga Tiket",
                "Masukkan Harga Tiket Disini",
                _hargaController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  } else if (!_isNumeric(value)) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),

              // Deskripsi
              _buildTextField(
                "Deskripsi",
                "Masukkan Deskripsi Disini",
                _deskripsiController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Tombol Simpan
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data berhasil disimpan!')),
                    );
                  }
                },
                child: const Text(
                  "Simpan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Tombol Reset
              TextButton(
                onPressed: _resetForm,
                child: const Text(
                  "Reset",
                  style: TextStyle(color: Color.fromARGB(255, 33, 80, 235)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Builder untuk TextField
  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label :",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  // Widget Builder untuk Dropdown
  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Jenis Wisata :",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _jenisWisata,
            decoration: InputDecoration(
              hintText: "Pilih Jenis Wisata",
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: "Pantai", child: Text("Pantai")),
              DropdownMenuItem(value: "Pegunungan", child: Text("Pegunungan")),
              DropdownMenuItem(value: "Taman", child: Text("Taman")),
              DropdownMenuItem(value: "Sejarah", child: Text("Sejarah")),
            ],
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Jenis wisata tidak boleh kosong'
                        : null,
            onChanged: (value) => setState(() => _jenisWisata = value),
          ),
        ],
      ),
    );
  }
}
