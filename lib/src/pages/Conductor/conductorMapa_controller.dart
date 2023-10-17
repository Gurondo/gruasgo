import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:gruasgo/src/utils/snackbar.dart' as utils;

class DriverMapController{
  BuildContext? context;
  Function? refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer <GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = CameraPosition(
      target: LatLng(-17.7818524,-63.1811685),
    zoom: 14.0
  );

  Map<MarkerId,Marker> markers = <MarkerId,Marker>{};   /// ULIZADO EN M3
  Position? _position;
  StreamSubscription<Position>? _positionStream;
  BitmapDescriptor? markerDriver;

  Future? init(BuildContext context, Function refresh) async{
     this.context = context;
     this.refresh = refresh;
     markerDriver = await createMarkerImageFromAsset('assets/img/icono_grua.png');  ////ULILIZADO EN M3
     checkGPS();
  }

  void onMapCreated(GoogleMapController controller){
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#ebe3cd"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#523735"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f1e6"}]},{"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#c9b2a6"}]},{"featureType":"administrative.land_parcel","elementType":"geometry.stroke","stylers":[{"color":"#dcd2be"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#ae9e90"}]},{"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#93817c"}]},{"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#a5b076"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#447530"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#f5f1e6"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#fdfcf8"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#f8c967"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#e9bc62"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#e98d58"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry.stroke","stylers":[{"color":"#db8555"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#806b63"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"transit.line","elementType":"labels.text.fill","stylers":[{"color":"#8f7d77"}]},{"featureType":"transit.line","elementType":"labels.text.stroke","stylers":[{"color":"#ebe3cd"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#b9d3c2"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#92998d"}]}]');
    _mapController.complete(controller);
  }

  void checkGPS() async{
    bool isLocationEnable = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnable){
      print('GPS ACTIVADO');
      updateLocation();
    }else{
      print('GPS DESACTIVADO ');
      bool locationGPS = await location.Location().requestService();
      if(locationGPS){
        updateLocation();
        print('ACTIVO EL GPS');
      }
    }
  }

  void updateLocation() async {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition();
      centerPosition();

      addMarker('driver', _position!.latitude, _position!.longitude, 'Tu posision', '',markerDriver!);   //// UTILIZADO EN M3
      refresh!();
      _positionStream = Geolocator.getPositionStream(
          //desiredAccuracy: LocationAccuracy.best,
          //distanceFilter: 1// filtrar actualizaciones a 10 metros
      ).listen((Position position) {
        _position = position;
        addMarker('driver', _position!.latitude, _position!.longitude, 'Tu posision', '',markerDriver!);   //// UTILIZADO EN M3
        animateCameraToPosition(_position!.latitude, _position!.longitude);
        refresh!();
      });
    } catch (error) {
      print('ERROR EN LA LOCALIZACIÓN: $error');
    }
  }


  void centerPosition(){
    if(_position != null){
      animateCameraToPosition(_position!.latitude, _position!.longitude);
    }else{
      utils.Snackbar.showSnackbar(context!, key, 'Activa el GPS para obtener la posicion');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null){
      controller.animateCamera(CameraUpdate.newCameraPosition(
         CameraPosition(
           bearing: 0,
           target: LatLng(latitude,longitude),
           zoom: 17,
         )
      ));
    }
  }
   ///**** M3 ******** CODIGO QUE AÑADE MARCADOR PERSONALIZADO AUTITO AMARILLO *************
  Future<BitmapDescriptor>? createMarkerImageFromAsset(String path) async{
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }
  void addMarker(String markerId, double lat, double lng, String title, String content, BitmapDescriptor iconMarker){
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
      markerId: id,
      icon: iconMarker,
      position: LatLng(lat,lng),
      infoWindow: InfoWindow(title: title, snippet: content),
      /// aqui animacion rotacion icono
      draggable: false,
      zIndex: 2,
      flat: true,
      anchor: Offset(0.5,0.5),
      rotation: _position!.heading
    );
    markers[id] = marker;
  }
  ///  PARA MOSTRAR EL DRAWER
  void openDrawer(){
    key.currentState?.openDrawer();
  }

  /// PARA CIERRE DE SESSION
  void cerrarSession() async{
    Navigator.pushNamedAndRemoveUntil(context!, 'login', (route) => false);
  }
}