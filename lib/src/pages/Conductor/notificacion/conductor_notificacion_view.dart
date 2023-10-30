import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/arguments/detalle_notificacion_conductor.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
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

  final int _tiempo = 10;

  var _pedidoAceptado = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _conductorBloc = BlocProvider.of<ConductorBloc>(context);

    final navigator = Navigator.of(context);
    _conductorBloc.solicitudCancelada(navigator: navigator);

  }

  @override
  void dispose() {
    _conductorBloc.respuestaPedido(detalleNotificacionConductor: args, pedidoAceptado: _pedidoAceptado);
    _conductorBloc.clearSolicitudCanceladaSocket();
    // TODO: implement dispose
    super.dispose();
  }

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

            Text('${args.monto.toString()} Bs.', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),

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
                        onPressed: (){
                          // _conductorBloc.aceptarPedido(socketClientId: args.socketClientId, clientId: args.clienteId);
                          _pedidoAceptado = true;
                          Navigator.pop(context);
                          Navigator.pushNamed(context, 'ConductorPedidoAceptado', arguments: args);
                        },
                      ),
                    ],
                  );
                }
              ),
            ),

            Linea(
              tiempo: _tiempo
            ),

            Countdown(
              seconds: _tiempo,
              build: (BuildContext context, double time) {
                return Container();
              },
              onFinished: (){
                Navigator.pop(context);
              },
            )

            
          ],
        )
      )
    );
  }
}

class Linea extends StatefulWidget {

  final int tiempo;

  const Linea({
    Key? key,
    required this.tiempo
  }) : super(key: key);


  @override
  State<Linea> createState() => _LineaState();
}

class _LineaState extends State<Linea> with TickerProviderStateMixin{

  late AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
    /// [AnimationController]s can be created with `vsync: this` because of
    /// [TickerProviderStateMixin].
    vsync: this,
      duration: Duration(seconds: widget.tiempo),
    )..addListener(() {
        setState(() {});
    });
    _controller.reverse(from: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      minHeight: 20,
      value: _controller.value
    );
  }
}