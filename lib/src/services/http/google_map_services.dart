
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GoogleMapServices{

  GoogleMapServices._();

  static Future<http.Response> googleDirections({required LatLng origen, required LatLng destino}) async{
    const key = 'AIzaSyAM_GlhLkiLrtgBL5G_Pteq1o1I-6C9ljA';
    var urlParce = Uri.parse('https://maps.googleapis.com/maps/api/directions/json?destination=${origen.latitude},${origen.longitude}&origin=${destino.latitude},${destino.longitude}&key=$key');
    final resp = await http.get(urlParce);
    return resp;
  }

}