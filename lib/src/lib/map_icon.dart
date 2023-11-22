import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapIcons {

  static BitmapDescriptor? iconConductor;
  static BitmapDescriptor? iconMarkerOrigen;
  static BitmapDescriptor? iconMarkerDestino;

  static Future<void> loadIcons() async {
    await Future.wait([
      cargariconConductor(),
      cargarIconMarkerOrigen(),
      cargarIconMarkerDestino()
    ]);
  }

  static Future<void> cargariconConductor()async{
    iconConductor = await _createMarkerImageFromAsset('assets/img/icon_grua.png');
  }
  static Future<void> cargarIconMarkerOrigen()async{
    iconMarkerOrigen = await _createMarkerImageFromAsset('assets/img/pinAA.png');
  }
  static Future<void> cargarIconMarkerDestino()async{
    iconMarkerDestino = await _createMarkerImageFromAsset('assets/img/pinBB.png');
  }

  static Future<BitmapDescriptor>? _createMarkerImageFromAsset(String path) async{
    ImageConfiguration configuration = const ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }
}