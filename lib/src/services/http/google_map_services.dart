
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/global/enviroment.dart';
import 'package:http/http.dart' as http;

class GoogleMapServices{

  GoogleMapServices._();

  static Future<http.Response> googleDirections({required LatLng origen, required LatLng destino}) async{
    const key = 'AIzaSyAM_GlhLkiLrtgBL5G_Pteq1o1I-6C9ljA';
    var urlParce = Uri.parse('https://maps.googleapis.com/maps/api/directions/json?destination=${destino.latitude},${destino.longitude}&origin=${origen.latitude},${origen.longitude}&key=$key');
    final resp = await http.get(urlParce);
    return resp;
  }

  static Future<http.Response> getDistancia({
    required LatLng origen,
    required LatLng destino,
    required String servicio
  }) async {

    final data = {
      'lat_origen': origen.latitude,
      'lng_origen': origen.longitude,
      'lat_destino': destino.latitude,
      'lng_destino': destino.longitude,
      'servicio': servicio
    };

    var urlParse = Uri.parse('${Enviroment().server}/map');

    final response = await http.post(
      urlParse, 
      body: jsonEncode(data),       
      headers: {
        'Content-Type': 'application/json'
      }
    );


    return response;
  
  }

}