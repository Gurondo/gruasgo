import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/widgets/google_map_widget.dart';

class ConductorNotificacion extends StatefulWidget {
  
  const ConductorNotificacion({ Key? key }) : super(key: key);

  @override
  State<ConductorNotificacion> createState() => _ConductorNotificacionState();
}

class _ConductorNotificacionState extends State<ConductorNotificacion> {

  final Completer <GoogleMapController> _mapController = Completer();

  @override
  Widget build(BuildContext context) {
    
    final conductorBloc = BlocProvider.of<ConductorBloc>(context);
    LatLng origen = const LatLng(-17.7945792, -63.1851922);
    LatLng destino = const LatLng(-17.7924952, -63.1806647);
    
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
                              title: 'Destino',
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    margin: const EdgeInsets.all(8),
                    child: const Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 1,
                      child: Text('Cliente: Carlos Alberto Salguero Melendres')),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  Text('Recoger en', style: TextStyle(fontWeight: FontWeight.bold),),
                  Text('Calle 10 ##34,07, Pasto, Nariño'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  Text('Llegar a', style: TextStyle(fontWeight: FontWeight.bold),),
                  Text('Calle 10 ##34,07, Pasto, Nariño'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  Text('Carga a recoger', style: TextStyle(fontWeight: FontWeight.bold),),
                  Text('VAGONETA TOYOTA 4 RUNNER 2018'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  Text('Referencia', style: TextStyle(fontWeight: FontWeight.bold),),
                  Text('Recoger de la plaza Llamar al 77532414 al Sr.'),
                ],
              ),
            ),

            const Text('28', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Builder(
                builder: (context) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ButtonApp(
                        paddingHorizontal: 30,
                        text: 'Cancelar',
                        color: Colors.amber,
                        textColor: Colors.black,
                        icons: Icons.cancel_outlined
                      ),
                      ButtonApp(
                        paddingHorizontal: 30,
                        text: 'Aceptar',
                        color: Colors.blue[400],
                        textColor: Colors.white,
                        icons: Icons.check,
                      ),
                    ],
                  );
                }
              ),
            )
            
          ],
        )
      )
    );
  }
}