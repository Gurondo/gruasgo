import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/arguments/detalle_notificacion_conductor.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
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
                  FutureBuilder<List<PointLatLng>?>(
                    future: conductorBloc.getPolylines(origen: origen, destino: destino),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting){
                        return const Text('Cargando');
                      }
                      if (snapshot.data == null){
                        return const Text('Algo salio mal');
                      }
                      return GoogleMapWidget(
                        initPosition: origen, 
                        googleMapController: _mapController,
                        markers: {
                          Marker(
                            markerId: const MarkerId('origen'),
                            position: origen
                          ),
                          Marker(
                            markerId: const MarkerId('destino'),
                            position: destino,
                            infoWindow: const InfoWindow(
                              title: 'Destino'
                            )
                          ),
                        },
                        polylines: {
                          Polyline(
                            polylineId: const PolylineId('ruta'),
                            color: Colors.black,
                            width: 5,
                            points: snapshot.data!.map((e) => LatLng(e.latitude, e.longitude)).toList()
                          )
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