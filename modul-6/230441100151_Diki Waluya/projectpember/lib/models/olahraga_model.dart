class Olahraga {
  final String nama;
  final String durasi;
  final String deskripsi;
  final String urlGambar;
  final int kaloriBurn;

  Olahraga({
    required this.nama,
    required this.durasi,
    required this.deskripsi,
    required this.urlGambar,
    required this.kaloriBurn,
  });

  factory Olahraga.fromMap(Map<String, dynamic> map) {
    return Olahraga(
      nama: map['nama'],
      durasi: map['durasi'],
      deskripsi: map['deskripsi'],
      urlGambar: map['url_gambar'],
      kaloriBurn: map['kalori_burn'],
    );
  }
}
