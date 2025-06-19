// Pastikan import sesuai
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path/path.dart' as p;
import 'package:device_info_plus/device_info_plus.dart';

import '../models/food_item.dart';
import '../services/cloudinary_service.dart';
import '../services/food_service.dart';

class FoodListScreen extends StatefulWidget {
  final String firebaseUid;
  const FoodListScreen({super.key, required this.firebaseUid});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final List<FoodItem> foodItems = [];
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _kaloriController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _imageUrlController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  FoodItem? _editingItem;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    try {
      final fetchedFoods = await FoodService.getFoodsByUser(widget.firebaseUid);
      setState(() {
        foodItems
          ..clear()
          ..addAll(fetchedFoods);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengambil data: $e")));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    PermissionStatus permissionStatus;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        permissionStatus = await Permission.photos.request();
      } else {
        permissionStatus = await Permission.storage.request();
      }
    } else {
      permissionStatus = await Permission.photos.request();
    }

    if (!permissionStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin akses gambar ditolak.")),
      );
      return;
    }

    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _selectedImage = file;
        _imageUrlController.clear();
      });

      final bytes = await file.readAsBytes();
      await ImageGallerySaverPlus.saveImage(
        bytes,
        name: p.basename(file.path),
        quality: 100,
      );

      try {
        final url = await CloudinaryService.uploadImage(file);
        setState(() => _imageUrlController.text = url);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal upload gambar: $e")));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (BuildContext ctx) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.white),
                  title: const Text(
                    'Ambil dari Kamera',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.white),
                  title: const Text(
                    'Pilih dari Galeri',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  // edit

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi semua data!")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final food = FoodItem(
        id: _editingItem?.id,
        firebaseUid: widget.firebaseUid,
        name: _nameController.text,
        description: _descController.text,
        kalori: int.tryParse(_kaloriController.text) ?? 0,
        jumlah: int.tryParse(_jumlahController.text) ?? 0,
        tanggal:
            _editingItem != null
                ? ''
                : _selectedDate.toIso8601String().split('T').first,
        imageUrl: _imageUrlController.text,
      );

      final success =
          _editingItem != null
              ? await FoodService.updateFood(food)
              : await FoodService.createFood(food);

      if (success) {
        if (_editingItem != null) {
          final index = foodItems.indexWhere((f) => f.id == _editingItem!.id);
          if (index != -1) {
            setState(() => foodItems[index] = food);
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Berhasil diperbarui")));
        } else {
          await _loadFoods();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Berhasil disimpan")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan ke server")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      Navigator.of(context).pop();
      _resetForm();
    }
  }

  void _resetForm() {
    _nameController.clear();
    _descController.clear();
    _kaloriController.clear();
    _jumlahController.clear();
    _imageUrlController.clear();
    _selectedDate = DateTime.now();
    _selectedImage = null;
    _editingItem = null;
  }

  void _fillFormWithItem(FoodItem item) {
    setState(() {
      _editingItem = item;
      _nameController.text = item.name;
      _descController.text = item.description;
      _kaloriController.text = item.kalori.toString();
      _jumlahController.text = item.jumlah.toString();
      _selectedDate = DateTime.tryParse(item.tanggal) ?? DateTime.now();
      _imageUrlController.text = item.imageUrl;
    });
  }

  Future<void> _deleteItem(FoodItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Hapus Makanan"),
            content: const Text("Apakah kamu yakin ingin menghapus item ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true && item.id != null) {
      final success = await FoodService.deleteFood(item.id!, item.firebaseUid);
      if (success) {
        setState(() => foodItems.removeWhere((f) => f.id == item.id));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Berhasil dihapus')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menghapus data')));
      }
    }
  }

  //deskrisi
  Widget _buildFoodList() {
    if (foodItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Text(
          'Belum ada data makanan.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        final item = foodItems[index];
        return Card(
          elevation: 6,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: const Color(0xFF1A1A2E),
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  item.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kalori: ${item.kalori} kkal',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Jumlah: ${item.jumlah} g',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tanggal: ${item.tanggal}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () => _fillFormWithItem(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteItem(item),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //simpan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C1D),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0D0C1D),
        centerTitle: true,
        title: const Text('Catat Makanan Anda'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal: ${_selectedDate.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  border: Border.all(color: Colors.white30),
                  borderRadius: BorderRadius.circular(8),
                  image:
                      _selectedImage != null
                          ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                          : (_imageUrlController.text.isNotEmpty
                              ? DecorationImage(
                                image: NetworkImage(_imageUrlController.text),
                                fit: BoxFit.cover,
                              )
                              : null),
                ),
                alignment: Alignment.center,
                child:
                    _selectedImage == null && _imageUrlController.text.isEmpty
                        ? const Text(
                          'Klik untuk pilih gambar',
                          style: TextStyle(color: Colors.white70),
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Nama Makanan'),
                  _buildTextField(_descController, 'Deskripsi'),
                  _buildTextField(_kaloriController, 'Kalori', isNumber: true),
                  _buildTextField(
                    _jumlahController,
                    'Jumlah (gram)',
                    isNumber: true,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: Icon(_editingItem != null ? Icons.edit : Icons.save),
                    label: Text(
                      _editingItem != null
                          ? "Update Makanan"
                          : "Simpan Makanan",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_editingItem != null)
                    TextButton(
                      onPressed: _resetForm,
                      child: const Text(
                        "Batal Edit",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            _buildFoodList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }
}
