import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenStreetMapGymService {
  Future<List<Map<String, dynamic>>> fetchNearbyGyms(double lat, double lng) async {
    final radiusInMeters = 35000;
    final overpassUrl = 'https://overpass-api.de/api/interpreter';

    final query = """
    [out:json];
    (
      node["leisure"="fitness_centre"](around:$radiusInMeters,$lat,$lng);
      way["leisure"="fitness_centre"](around:$radiusInMeters,$lat,$lng);
      relation["leisure"="fitness_centre"](around:$radiusInMeters,$lat,$lng);
    );
    out center;
    """;
final response = await http.post(
  Uri.parse(overpassUrl),
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded',
    'User-Agent': 'FlutterGymFinder/1.0 (mayieatyourcake@gmail.com)',
  },
  body: 'data=${Uri.encodeComponent(query)}',
);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List elements = jsonData['elements'];

      return elements
          .map<Map<String, dynamic>?>((e) {
            final latVal = e['lat'] ?? e['center']?['lat'];
            final lonVal = e['lon'] ?? e['center']?['lon'];
            if (latVal == null || lonVal == null) return null;
            return {
              'nama': e['tags']?['name'] ?? 'Gym tanpa nama',
              'lat': latVal,
              'lng': lonVal,
            };
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    } else {
      print("Overpass error: ${response.statusCode}");
      return [];
    }
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
  final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1');

  final response = await http.get(url, headers: {
    'User-Agent': 'FlutterGymFinder/1.0 (mayieatyourcake@gmail.com)',
  });

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final address = data['address'];

    String alamat = '';
    if (address['road'] != null) alamat += '${address['road']}, ';
    if (address['suburb'] != null) alamat += '${address['suburb']}, ';
    if (address['village'] != null) alamat += '${address['village']}, ';
    if (address['town'] != null) alamat += '${address['town']}, ';
    if (address['city_district'] != null) alamat += '${address['city_district']}, ';
    if (address['county'] != null) alamat += '${address['county']}, ';
    if (address['state'] != null) alamat += '${address['state']}';

    return alamat.isNotEmpty ? alamat : 'Alamat tidak ditemukan';
  } else {
    print("Gagal reverse geocoding (${response.statusCode})");
    return 'Alamat tidak tersedia';
  }
}

}
