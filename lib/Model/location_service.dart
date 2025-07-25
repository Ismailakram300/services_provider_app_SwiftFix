import 'dart:developer';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log("Location services are disabled   .");
        return null;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        log("Location permission denied.");

        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          log("Location permission not granted.");
          return null;
        }
      }

      //get loc
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      log("Error getting location: $e");
      return null;
    }
  }
  Future<Map<String, String>> getAddressFromLatLng(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark place = placemarks[0];
      return {
        "address": '${place.street}, ${place.locality}, ${place.country}',
        "city": place.locality ?? "Unknown City",
      };
    } catch (e) {
      log("Error getting address: $e");
      return {
        "address": "Unknown Address",
        "city": "Unknown City",
      };
    }
  }
}
