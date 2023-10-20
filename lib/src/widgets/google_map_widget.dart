import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gruasgo/src/global/enviroment.dart';

class GoogleMapWidget extends StatelessWidget {

  final LatLng initPosition;
  final Completer<GoogleMapController> controllerxD;
  final Set<Marker> markers;
  final Function(LatLng)? onTap;

  const GoogleMapWidget({
    super.key,
    this.onTap,
    this.markers = const {},
    required this.initPosition,
    required this.controllerxD,
  });

  @override
  Widget build(BuildContext context) {


    return GoogleMap(
      polylines: {},
      initialCameraPosition: CameraPosition(
        target: LatLng(initPosition.latitude, initPosition.longitude),
        zoom: 18.151926040649414
      ),
      markers: markers,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        controllerxD.complete(controller);
      },
      onCameraMove: (position) {
        
      },
      onTap: onTap,
    );
  }
}