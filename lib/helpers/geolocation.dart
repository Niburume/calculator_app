import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeoLocation {
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      await Geolocator.openLocationSettings();
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<Map<String, dynamic>> getCurrentPosition() async {
    Map<String, dynamic> geoData = {};
    Position position = await Geolocator.getCurrentPosition();
    List newPlace =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placeMark = newPlace[0];
    String address =
        "${placeMark.name}, ${placeMark.postalCode} ${placeMark.subLocality}";
    geoData['address'] = address;
    geoData['latitude'] = position.latitude;
    geoData['longitude'] = position.longitude;

    return geoData;
  }
}
