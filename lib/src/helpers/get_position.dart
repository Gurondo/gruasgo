import 'package:geolocator/geolocator.dart';

Future<Position> getPositionHelpers() async {
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  return position;
}

