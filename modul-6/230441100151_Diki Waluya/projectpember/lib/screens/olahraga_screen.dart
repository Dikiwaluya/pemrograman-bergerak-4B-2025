import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/olahraga_services.dart';
import '../services/openstreetmap_gym_service.dart';
import '../services/notification_service.dart';
import '../models/olahraga_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../utils/alaram_permission_helper.dart';
class JadwalScreen extends StatefulWidget {
  const JadwalScreen({Key? key}) : super(key: key);

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final _olahragaService = OlahragaService();
  final _gymService = OpenStreetMapGymService();
  final Color primaryColor = const Color(0xFFF4C430);
  final Color darkBg = const Color(0xFF121212);
  final Color cardBg = const Color(0xFF1E1E1E);

  List<Map<String, dynamic>> jadwalMingguan = [];
  List<Map<String, dynamic>> nearbyGyms = [];
  final List<String> hari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  Position? currentPosition;
  String? currentAddress;
  bool isFetchingGyms = false;

  @override
  void initState() {
    super.initState();
    NotificationService().init();
    _mintaIzinNotifikasi();
    requestExactAlarmPermission();
    generateJadwal();
    determinePosition();
  }

  void _mintaIzinNotifikasi() async {
    final FlutterLocalNotificationsPlugin plugin =
        FlutterLocalNotificationsPlugin();
    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    final bool? granted = await androidImpl?.requestPermission();
    debugPrint("Izin notifikasi diberikan: $granted");
  }
Future<void> requestExactAlarmPermission() async {
  if (Platform.isAndroid) {
    final allowed = await AlarmPermissionHelper.isExactAlarmAllowed();
    if (!allowed) {
      const intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
    } else {
      debugPrint("Izin alarm exact sudah diberikan");
    }
  }
}
  Future<void> generateJadwal() async {
    final olahragaList = await _olahragaService.fetchOlahragaList();
    if (olahragaList.length < 5) return;

    olahragaList.shuffle();
    final selected = olahragaList.take(5).toList();

    List<String> statusHari = List.generate(7, (_) => 'Olahraga');
    int count = 0;
    final random = Random();
    while (count < 2) {
      int idx = random.nextInt(7);
      if (statusHari[idx] != 'Istirahat') {
        statusHari[idx] = 'Istirahat';
        count++;
      }
    }

    List<Map<String, dynamic>> jadwal = [];
    int index = 0;
    for (int i = 0; i < 7; i++) {
      if (statusHari[i] == 'Istirahat') {
        jadwal.add({'hari': hari[i], 'istirahat': true});
      } else {
        final o = selected[index++];
        jadwal.add({'hari': hari[i], 'istirahat': false, 'olahraga': o});
      }
    }

    setState(() => jadwalMingguan = jadwal);
  }

  Future<void> determinePosition() async {
    await Geolocator.requestPermission();
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final address = await _gymService.getAddressFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    setState(() {
      currentPosition = pos;
      currentAddress = address;
    });
  }

  Future<void> cariGymTerdekat() async {
    if (currentPosition == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: cardBg,
            title: Text(
              "Konfirmasi Lokasi",
              style: TextStyle(color: primaryColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$currentAddress",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Koordinat:\nLat: ${currentPosition!.latitude}, Lng: ${currentPosition!.longitude}",
                  style: const TextStyle(color: Colors.white70),
                ),
                TextButton(
                  onPressed: () {
                    final url =
                        "https://www.google.com/maps?q=${currentPosition!.latitude},${currentPosition!.longitude}";
                    launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Text(
                    "Lihat di Google Maps",
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Cari",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => isFetchingGyms = true);
    final gyms = await _gymService.fetchNearbyGyms(
      currentPosition!.latitude,
      currentPosition!.longitude,
    );

    final gymList = <Map<String, dynamic>>[];
    for (final gym in gyms) {
      final dist =
          Geolocator.distanceBetween(
            currentPosition!.latitude,
            currentPosition!.longitude,
            gym['lat'],
            gym['lng'],
          ) /
          1000;
      if (dist <= 35.0) {
        final address = await _gymService.getAddressFromCoordinates(
          gym['lat'],
          gym['lng'],
        );
        gymList.add({...gym, 'alamat': address, 'jarak': dist});
      }
    }

    setState(() {
      nearbyGyms = gymList;
      isFetchingGyms = false;
    });
  }

  void openMaps(double lat, double lng) {
    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving",
    );
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _showTimerDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: cardBg,
            title: Text(
              "Atur Durasi Olahraga",
              style: TextStyle(color: primaryColor),
            ),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Masukkan durasi dalam menit",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final durasi = int.tryParse(controller.text);
                  if (durasi != null && durasi > 0) {
                    await NotificationService().scheduleExerciseEndNotification(
                      minutes: durasi,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Notifikasi akan dikirim dalam $durasi menit",
                          ),
                        ),
                      );
                    }
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text(
                  "Setel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: Text(
          "Let's Do Exercise",
          style: TextStyle(
            color: primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body:
          currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...jadwalMingguan.map((item) {
                      if (item['istirahat']) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellow.shade800,
                                Colors.orange.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.hotel,
                              color: Colors.white,
                            ),
                            title: Text(
                              item['hari'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Hari Istirahat • Recovery",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      }

                      final olahraga = item['olahraga'] as Olahraga;
                      return Card(
                        color: cardBg,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                olahraga.urlGambar,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      height: 180,
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.white,
                                      ),
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${item['hari']} - ${olahraga.nama}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Durasi: ${olahraga.durasi}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    "Kalori: ${olahraga.kaloriBurn} kal",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    "Deskripsi: ${olahraga.deskripsi}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: _showTimerDialog,
                                    icon: const Icon(Icons.timer),
                                    label: const Text("Set Timer for Exercise"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        "Gym Terdekat",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Center(
                      child: ElevatedButton.icon(
                        onPressed: isFetchingGyms ? null : cariGymTerdekat,
                        icon: const Icon(Icons.search),
                        label: Text(
                          isFetchingGyms ? "Mencari..." : "Cari Gym Terdekat",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (isFetchingGyms)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),

                    ...nearbyGyms.map((gym) {
                      return Card(
                        color: cardBg,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gym['nama'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                gym['alamat'],
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                "Jarak: ${gym['jarak']?.toStringAsFixed(2)} km",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      () => openMaps(gym['lat'], gym['lng']),
                                  icon: const Icon(Icons.navigation),
                                  label: const Text("Navigasi"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
    );
  }
}
