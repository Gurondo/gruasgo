import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';

Marker? getMarkerHelper ({
  required Set<Marker> markers,
  required MarkerIdEnum id
}) {
  Marker? marker;
  for (var elementMarker in markers) {
    if (elementMarker.markerId.value == id.toString()){
      marker = elementMarker;
      break;
    }
  }
  return marker;
}