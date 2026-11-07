import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'pusher_hub.dart';

/// PusherHub's optional location add-on, only for an app that already uses
/// location: one that already asks for a location permission itself, and
/// so already declares it for Android and iOS. Pass it to PusherHub:
///
///     final pusherHub = PusherHub(..., location: pusherHubLocation);
///
/// It never asks for a permission. It reads the phone's location only when
/// the person has already allowed it for this app, and returns null
/// otherwise, so PusherHub finds state and city from the IP address. Needs
/// geolocator and geocoding in pubspec.yaml, which an app that uses location
/// usually has already.
Future<PusherHubPlace?> pusherHubLocation() async {
  if (!await Geolocator.isLocationServiceEnabled()) return null;

  final permission = await Geolocator.checkPermission();
  if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
    return null;
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
  );

  // The phone's own free geocoder (Android's Geocoder, iOS's CLGeocoder): no API key.
  final placemarks = await Geocoding().placemarkFromCoordinates(position.latitude, position.longitude);
  if (placemarks.isEmpty) return null;

  final placemark = placemarks.first;

  return PusherHubPlace(
    state: placemark.administrativeArea,
    city: placemark.locality,
    country: placemark.country,
  );
}
