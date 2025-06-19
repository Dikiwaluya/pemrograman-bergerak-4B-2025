class FoodItem {
  final int? id;
  final String firebaseUid;
  final String name;
  final String description;
  final int kalori;
  final int jumlah;
  final String tanggal; // format: 'yyyy-MM-dd'
  final String imageUrl;

  FoodItem({
    this.id,
    required this.firebaseUid,
    required this.name,
    required this.description,
    required this.kalori,
    required this.jumlah,
    required this.tanggal,
    required this.imageUrl,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      firebaseUid: json['firebase_uid'] ?? '',
      name: json['nama_makanan'] ?? '',
      description: json['description'] ?? '',
      kalori: int.tryParse(json['kalori'].toString()) ?? 0,
      jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
      tanggal: json['tanggal'] ?? '',
      imageUrl: json['foto_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'firebase_uid': firebaseUid,
      'nama_makanan': name,
      'description': description,
      'kalori': kalori,
      'jumlah': jumlah,
      'tanggal': tanggal,
      'foto_url': imageUrl,
    };
  }
}
