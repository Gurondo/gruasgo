import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapIcons {

  static BitmapDescriptor? iconConductorDelCliente;
  static BitmapDescriptor? iconMarkerOrigen;
  static BitmapDescriptor? iconMarkerDestino;

  static Future<void> loadIcons() async {
    await Future.wait([
      cargarIconConductorDelCliente(),
      cargarIconMarkerOrigen(),
      cargarIconMarkerDestino()
    ]);
  }

  static Future<void> cargarIconConductorDelCliente()async{
    iconConductorDelCliente = await _createMarkerImageFromAsset('assets/img/icon_truc.png');
  }
  static Future<void> cargarIconMarkerOrigen()async{
    iconMarkerOrigen = await _createMarkerImageFromAsset('assets/img/pinA.png');
  }
  static Future<void> cargarIconMarkerDestino()async{
    iconMarkerDestino = await _createMarkerImageFromAsset('assets/img/pinB.png');
  }

  static Future<BitmapDescriptor>? _createMarkerImageFromAsset(String path) async{
    ImageConfiguration configuration = const ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }
}