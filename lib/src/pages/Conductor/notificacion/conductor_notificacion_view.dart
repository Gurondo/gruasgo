import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/arguments/detalle_notificacion_conductor.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/enum/polyline_id_enum.dart';
import 'package:gruasgo/src/global/enviroment.dart';
import 'package:gruasgo/src/helpers/helpers.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/widgets/google_map_widget.dart';
import 'package:timer_count_down/timer_count_down.dart';



class ConductorNotificacion extends StatefulWidget {
  
  const ConductorNotificacion({ Key? key }) : super(key: key);

  @override
  State<ConductorNotificacion> createState() => _ConductorNotificacionState();
}

class _ConductorNotificacionState extends State<ConductorNotificacion> {

  final Completer <GoogleMapController> _mapController = Completer();

  late ConductorBloc _conductorBloc;
  late DetalleNotificacionConductor args;

  final int _tiempo = Enviroment().tiempoEspera;

  var _pedidoAceptado = false;

  // Para estar escuchando eventos, si el cliente cancela el pedido o ya a sido aceptado por un conductor, este conductor puede ver el mensaje.
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _conductorBloc = BlocProvider.of<ConductorBloc>(context);

    _conductorBloc.solicitudYaTomada();

    final navigator = Navigator.of(context);
    _conductorBloc.solicitudCancelada(navigator: navigator);

  }
   // Para limpiar de la memoria
  @override
  void dispose() async {
    _conductorBloc.respuestaPedido(detalleNotificacionConductor: args, pedidoAceptado: _pedidoAceptado);
    if (!_pedidoAceptado){
      _conductorBloc.add(OnSetDetallePedido(null));
      _conductorBloc.add(OnSetNewMarkets({}));
    }

    // Limpiar de memoria
    _conductorBloc.clearSolicitudCanceladaSocket();
    _conductorBloc.clearSolicitudYaTomadaSocket();
    // TODO: implement dispose
    super.dispose();
  }

  // diseño basico con sus funcionalidades
  @override
  Widget build(BuildContext context) {

    args = ModalRoute.of(context)!.settings.arguments as DetalleNotificacionConductor;
    _conductorBloc = BlocProvider.of<ConductorBloc>(context);


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
                    future: _conductorBloc.getPolylines(origen: origen, destino: destino),
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
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 1,
                      child: Text('Cliente: ${args.cliente}')),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  const Text('Recoger en', style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(args.nombreOrigen),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  const Text('Llegar a', style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(args.nombreDestino),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  const Text('Carga a recoger', style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(args.descripcionDescarga),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  const Text('Referencia', style: TextStyle(fontWeight: FontWeight.bold),),
                  Text('Llamar al numero: ${args.referencia.toString()}'),
                ],
              ),
            ),

            Countdown(
              seconds: _tiempo,
              build: (BuildContext context, double time) {
                return Text(
                  time.toStringAsFixed(time.truncateToDouble() == time ? 0 : 1),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                );
              },
              onFinished: (){
                Navigator.pop(context);
              },
            ),
            // Text('${args.monto.toString()} Bs.', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Builder(
                builder: (context) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ButtonApp(
                        paddingHorizontal: 20,
                        text: 'Cancelar',
                        color: Colors.amber,
                        textColor: Colors.black,
                        icons: Icons.cancel_outlined,
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                      ButtonApp(
                        paddingHorizontal: 20,
                        text: 'Aceptar',
                        color: Colors.blue[400],
                        textColor: Colors.white,
                        icons: Icons.check,
                        onPressed: () async {
                          // _conductorBloc.aceptarPedido(socketClientId: args.socketClientId, clientId: args.clienteId);
                          _conductorBloc.add(OnSetNewMarkets({
                            Marker(
                              markerId: MarkerId(MarkerIdEnum.origen.toString()),
                              position: args.origen
                            ),
                            Marker(
                              markerId: MarkerId(MarkerIdEnum.destino.toString()),
                              position: args.destino
                            ),
                          }));
                          
                          _getPolylines();

                          _pedidoAceptado = true;
                          Navigator.pop(context);
                          _conductorBloc.add(OnSetDetallePedido(args));
                        },
                      ),
                    ],
                  );
                }
              ),
            ),

            // Linea(
            //   tiempo: _tiempo
            // ),
            
          ],
        )
      )
    );
  }

  Future _getPolylines() async {
      Position position = await getPositionHelpers();
      
      List<PointLatLng>? polyline = await _conductorBloc.getPolylines(
        origen: LatLng(position.latitude, position.longitude), 
        destino: args.origen
      );

      if (polyline != null){
        _conductorBloc.add(OnSetAddPolyline(
          Polyline(
            polylineId: PolylineId(PolylineIdEnum.posicionToOrigen.toString()),
            color: Colors.black,
            width: 4,
            points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
          )
        ));
      }
  }

}