import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class FarmerLocation {
  final double latitude;
  final double longitude;
  final String district;
  final String state;
  final String formattedAddress;

  const FarmerLocation({
    required this.latitude,
    required this.longitude,
    required this.district,
    required this.state,
    required this.formattedAddress,
  });

  factory FarmerLocation.defaultLocation() {
    return const FarmerLocation(
      latitude: 17.9689,
      longitude: 79.5941,
      district: 'Warangal',
      state: 'Telangana',
      formattedAddress: 'Warangal, Telangana',
    );
  }
}

class LocationService {
  Future<FarmerLocation> getCurrentFarmerLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return FarmerLocation.defaultLocation();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return FarmerLocation.defaultLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return FarmerLocation.defaultLocation();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );

      // Reverse geocode to find District & State name
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final district = p.subAdministrativeArea?.isNotEmpty == true
              ? p.subAdministrativeArea!
              : p.locality ?? 'Regional';
          final state = p.administrativeArea ?? 'India';

          return FarmerLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            district: district,
            state: state,
            formattedAddress: '$district, $state',
          );
        }
      } catch (_) {}

      return FarmerLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        district: 'Regional Farm Area',
        state: 'India',
        formattedAddress: 'GPS Location (${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})',
      );
    } catch (e) {
      if (kDebugMode) {
        print('GPS location fallback: $e');
      }
      return FarmerLocation.defaultLocation();
    }
  }
}
