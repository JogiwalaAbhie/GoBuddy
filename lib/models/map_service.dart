import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class MapService {
  static final MapController mapController = MapController();

  static Future<LatLng?> fetchCoordinates(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print("❌ Error fetching coordinates: $e");
    }
    return null;
  }

  static Future<LatLng?> fetchUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  static Future<void> openGoogleMaps(BuildContext context,
      LatLng? currentLocation, LatLng? destinationLocation) async {
    if (currentLocation == null || destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fetching location... Please wait.")),
      );
      return;
    }

    final Uri url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&origin=${currentLocation.latitude},${currentLocation.longitude}&destination=${destinationLocation.latitude},${destinationLocation.longitude}&travelmode=driving",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw "Could not open Google Maps";
    }
  }
}