import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/helpers/get_marker.dart';

// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:gruasgo/src/global/enviroment.dart';

class GoogleMapWidget extends StatelessWidget {
  

  final LatLng initPosition;
  final Completer<GoogleMapController> googleMapController;
  final Set<Marker> markers;
  final Function(LatLng)? onTap;
  final Set<Polyline> polylines;
  final double zoom;
  final Function()? onCameraMoveStarted;
  final bool ajustarZoomOrigenDestino;
  final bool myLocationEnabled;


  const GoogleMapWidget({
    super.key,
    this.onTap,
    this.polylines = const {},
    this.markers = const {},
    this.zoom = 18.151926040649414,
    this.onCameraMoveStarted,
    this.ajustarZoomOrigenDestino = false,
    this.myLocationEnabled = true,
    required this.initPosition,
    required this.googleMapController,
  });

  @override
  Widget build(BuildContext context) {
    

    return GoogleMap(
      myLocationEnabled: myLocationEnabled,
      zoomControlsEnabled: false,
      buildingsEnabled: false,
      polylines: polylines,
      initialCameraPosition: CameraPosition(
        target: LatLng(initPosition.latitude, initPosition.longitude),
        zoom: zoom
      ),
      markers: markers,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#ebe3cd"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#523735"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f1e6"}]},{"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#c9b2a6"}]},{"featureType":"administrative.land_parcel","elementType":"geometry.stroke","stylers":[{"color":"#dcd2be"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#ae9e90"}]},{"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#93817c"}]},{"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#a5b076"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#447530"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#f5f1e6"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#fdfcf8"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#f8c967"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#e9bc62"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#e98d58"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry.stroke","stylers":[{"color":"#db8555"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#806b63"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"transit.line","elementType":"labels.text.fill","stylers":[{"color":"#8f7d77"}]},{"featureType":"transit.line","elementType":"labels.text.stroke","stylers":[{"color":"#ebe3cd"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#b9d3c2"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#92998d"}]}]');
        
        if (!googleMapController.isCompleted) {
          googleMapController.complete(controller);


            // despues de 1 segundo, ajustar el zoom para que se vea todo el mapa
            if (ajustarZoomOrigenDestino){
              Future.delayed(const Duration(seconds: 1), () {
              
                Marker? origen = getMarkerHelper(markers: markers, id: MarkerIdEnum.origen);
                Marker? destino = getMarkerHelper(markers: markers, id: MarkerIdEnum.destino);
                if (origen != null && destino != null){
                  LatLngBounds bounds = LatLngBounds(
                    southwest: LatLng(
                      origen.position.latitude < destino.position.latitude ? origen.position.latitude : destino.position.latitude,
                      origen.position.longitude < destino.position.longitude ? origen.position.longitude : destino.position.longitude,
                    ),
                    northeast: LatLng(
                      origen.position.latitude > destino.position.latitude ? origen.position.latitude : destino.position.latitude,
                      origen.position.longitude > destino.position.longitude ? origen.position.longitude : destino.position.longitude,
                    ),
                  );
                  controller.animateCamera(
                    CameraUpdate.newLatLngBounds(
                      bounds,
                      100.0, // Puedes ajustar este valor según sea necesario
                    ),
                  );
                }

              });
            }
          
          
        }

      },


      onCameraMove: (position) {
        
      },

      onCameraMoveStarted: onCameraMoveStarted,
      
      onTap: onTap,
    );
  }

  void _adjustZoom({required LatLng  origen, required LatLng destino, required controller}) {
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        origen.latitude < destino.latitude ? origen.latitude : destino.latitude,
        origen.longitude < destino.longitude ? origen.longitude : destino.longitude,
      ),
      northeast: LatLng(
        origen.latitude > destino.latitude ? origen.latitude : destino.latitude,
        origen.longitude > destino.longitude ? origen.longitude : destino.longitude,
      ),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
  }
}