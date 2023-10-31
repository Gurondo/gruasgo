import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/arguments/informacion_conductor_cliente.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/helpers/get_position.dart';
import 'package:gruasgo/src/widgets/google_map_widget.dart';

class UsuarioPedidoAceptado extends StatefulWidget {
  const UsuarioPedidoAceptado({Key? key}) : super(key: key);

  @override
  State<UsuarioPedidoAceptado> createState() => _UsuarioPedidoAceptadoState();
}

class _UsuarioPedidoAceptadoState extends State<UsuarioPedidoAceptado> {
  final Completer<GoogleMapController> _mapController = Completer();

  late UsuarioPedidoBloc _usuarioPedidoBloc;

  @override
  void initState() {
    super.initState();

    _usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);

    _usuarioPedidoBloc.listenPosicionConductor();
  }

  @override
  void dispose() {
    _usuarioPedidoBloc.clearSocketPosicionConductor();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final argm = ModalRoute.of(context)!.settings.arguments
        as InformacionConductorCliente;

    return SafeArea(child: Scaffold(
      body: FutureBuilder<Position?>(
        future: getPositionHelpers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Text('Cargando');
          }
          return BlocBuilder<UsuarioPedidoBloc, UsuarioPedidoState>(
            builder: (context, state) {
              return GoogleMapWidget(
                  initPosition: LatLng(snapshot.data!.latitude,
                      snapshot.data!.longitude),
                  markers: {
                    // TODO: Flata aqui para saber donde esta la persona
                    Marker(
                        markerId: const MarkerId('conductor'),
                        position: LatLng(state.conductor!.latitude, state.conductor!.longitude),
                        infoWindow:
                            const InfoWindow(title: 'conductor')),
                    Marker(
                        markerId: const MarkerId('origen'),
                        position: state.origen!,
                        infoWindow:
                            const InfoWindow(title: 'origen')),
                    Marker(
                        markerId: const MarkerId('destino'),
                        position: state.destino!,
                        infoWindow:
                            const InfoWindow(title: 'destino')),
                  },
                  polylines: {
                    // Polyline(
                    //     polylineId:
                    //         const PolylineId('origen destino'),
                    //     color: Colors.blue,
                    //     width: 5,
                    //     points: snapshotOrigenDestino.data!
                    //         .map((e) =>
                    //             LatLng(e.latitude, e.longitude))
                    //         .toList()),
                    // Polyline(
                    //     polylineId:
                    //         const PolylineId('conductor origen'),
                    //     color: Colors.black,
                    //     width: 5,
                    //     points: snapshotConductorOrigen.data!
                    //         .map((e) =>
                    //             LatLng(e.latitude, e.longitude))
                    //         .toList()),
                  },
                  googleMapController: _mapController);
            },
          );
        },
      )
    ));
  }
}
