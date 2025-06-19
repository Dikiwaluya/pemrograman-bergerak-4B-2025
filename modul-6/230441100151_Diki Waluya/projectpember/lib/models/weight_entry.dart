class WeightEntry {
  final int? id;
  final double weight;
  final double height;
  final double? targetWeight;
  final DateTime createdAt;

  WeightEntry({
    this.id,
    required this.weight,
    required this.height,
    this.targetWeight,
    required this.createdAt,
  });

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: int.tryParse(json['id'].toString()),
      weight: double.tryParse(json['berat'].toString()) ?? 0,
      height: double.tryParse(json['tinggi'].toString()) ?? 0,
      targetWeight: json['target_berat'] != null
          ? double.tryParse(json['target_berat'].toString())
          : null,
      createdAt: DateTime.tryParse(json['tanggal']) ?? DateTime.now(),
    );
  }
}
