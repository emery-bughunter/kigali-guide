import 'package:geolocator/geolocator.dart';
class LocationService {
  static Future<Position?> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }
  static double distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) => Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  static String formatDistance(double km) => km < 1
      ? '${(km * 1000).toStringAsFixed(0)} m'
      : '${km.toStringAsFixed(1)} km';
}
