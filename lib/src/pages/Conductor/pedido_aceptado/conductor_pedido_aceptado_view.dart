import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/arguments/detalle_notificacion_conductor.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/helpers/get_position.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/widgets/widget.dart';

class ConductorPedidoAceptado extends StatefulWidget {
  const ConductorPedidoAceptado({ Key? key }) : super(key: key);

  @override
  State<ConductorPedidoAceptado> createState() => _ConductorPedidoAceptadoState();
}

class _ConductorPedidoAceptadoState extends State<ConductorPedidoAceptado> {

  final Completer <GoogleMapController> _mapController = Completer();

  @override
  Widget build(BuildContext context) {
    
    final conductorBloc = BlocProvider.of<ConductorBloc>(context);
    final args = ModalRoute.of(context)!.settings.arguments as DetalleNotificacionConductor;
    LatLng origen = args.origen;
    LatLng destino = args.destino;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // -------------------------------------------------
                  // Para sacar el polylines entre el origen y destino
                  // -------------------------------------------------
                  FutureBuilder<List<PointLatLng>?>(
                    future: conductorBloc.getPolylines(origen: origen, destino: destino),
                    builder: (context, snapshotConductor) {
                      if (snapshotConductor.connectionState == ConnectionState.waiting){
                        return const Text('Cargando');
                      }
                      if (snapshotConductor.data == null){
                        return const Text('Algo salio mal');
                      }
                      
                      // -------------------------------------------------
                      // Para obtener la posicion del usuario
                      // -------------------------------------------------

                      return FutureBuilder<Position>(
                        future: getPositionHelpers(),
                        builder: (context, snapshotPosition) {
                          
                          
                          if (snapshotPosition.connectionState == ConnectionState.done){
                            
                            // -------------------------------------------------
                            // para obtener el polyline entre el conductor hasta el punto de origen
                            // -------------------------------------------------
                                  
                            return FutureBuilder<List<PointLatLng>?>(
                              future: conductorBloc.getPolylines(
                                origen: LatLng(snapshotPosition.data!.latitude, snapshotPosition.data!.longitude), 
                                destino: origen
                              ),
                              builder: (context, snapshotConductorOrigen) {
                                
                                if (snapshotConductorOrigen.connectionState == ConnectionState.done){

                                  return GoogleMapWidget(
                                    initPosition: LatLng(snapshotPosition.data!.latitude, snapshotPosition.data!.longitude), 
                                    googleMapController: _mapController,
                                    markers: {
                                      Marker(
                                        markerId: const MarkerId('origen'),
                                        position: origen,
                                        infoWindow: const InfoWindow(title: 'Origen')
                                      ),
                                      Marker(
                                        markerId: const MarkerId('destino'),
                                        position: destino,
                                        infoWindow: const InfoWindow(title: 'Destino')
                                      ),
                                    },
                                    polylines: {
                                      Polyline(
                                        polylineId: const PolylineId('origen destino'),
                                        color: Colors.blue,
                                        width: 5,
                                        points: snapshotConductor.data!.map((e) => LatLng(e.latitude, e.longitude)).toList()
                                      ),
                                      
                                      Polyline(
                                        polylineId: const PolylineId('conductor origen'),
                                        color: Colors.black,
                                        width: 5,
                                        points: snapshotConductorOrigen.data!.map((e) => LatLng(e.latitude, e.longitude)).toList()
                                      ),

                                    },
                                  );

                                } else {
                                  return const Text('Cargando');
                                }
                                

                              },
                              
                            );
                          }else{
                            return const Text('error');
                          }



                        },

                      );
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 100),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ButtonApp(
                              text: 'Cancelar',
                              color: Colors.amber,
                              textColor: Colors.black,
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ButtonApp(
                      text: 'Estoy aqui',
                      color: Colors.amber,
                      textColor: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ButtonApp(
                      text: 'Finalizar Viaje',
                      color: Colors.amber,
                      textColor: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            )
          ],
        )
      )
    );
  }
}