
import 'package:geolocator/geolocator.dart';

class Geocoding {

  static final Geocoding _instance = Geocoding._();
  factory Geocoding() => _instance;
  Geocoding._();


  Future<String> locationReprFromPosition(Position position) async {
    String location;
    var placemarks = await Geolocator().placemarkFromPosition(position);
    if (placemarks.isNotEmpty) {
      var place = placemarks[0];
      location = place.subLocality + ", " + place.locality + ", " + place.country;
    }
    return location;
  }
}