import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/arguments/detalle_notificacion_conductor.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/models/response/google_map_direction.dart';
import 'package:gruasgo/src/services/http/google_map_services.dart';
import 'package:gruasgo/src/services/socket_services.dart';
import 'package:meta/meta.dart';

part 'conductor_event.dart';
part 'conductor_state.dart';

class ConductorBloc extends Bloc<ConductorEvent, ConductorState> {

  UserBloc userBloc;

  ConductorBloc({
    required this.userBloc
  }) : super(ConductorState()) {
    on<ConductorEvent>((event, emit) {
      // TODO: implement event handler
    });
  }

  Future<List<PointLatLng>?> getPolylines({
    required LatLng origen,
    required LatLng destino,
  }) async{
    
    // const key = 'AIzaSyAM_GlhLkiLrtgBL5G_Pteq1o1I-6C9ljA';
    // var urlParce = Uri.parse('https://maps.googleapis.com/maps/api/directions/json?destination=${origen.latitude},${origen.longitude}&origin=${destino.latitude},${destino.longitude}&key=$key');
    // final resp = await http.get(urlParce);

    final resp = await GoogleMapServices.googleDirections( origen: origen, destino: destino);
    
    if (resp.statusCode == 200){
      final googleMapDirection = googleMapDirectionFromJson(resp.body);
      return PolylinePoints().decodePolyline(googleMapDirection.routes[0].overviewPolyline.points);
    }
    return null;

  }

  void openSocket({required lat, required lng}) {
    SocketService.open();

    SocketService.emit('conductor online', {
      'id': userBloc.user?.idUsuario,
      'lat': lat,
      'lng': lng,
      'servicio': 'gruas'
    });

  }

  void closeSocket() {
    SocketService.close();
  }

  void updatePosition({required lat, required lng}){

    SocketService.emit('actualizar', {
      'lat': lat,
      'lng': lng
    });

  }

  void respuestaSolicitudConductor({required NavigatorState navigator}){

    SocketService.on('solicitud pedido conductor', (data){
      
      //     origen: [-17.8370698, -63.23666479999999], 
      //     destino: [-17.83886896671317, -63.23904678225518], 
      //     servicio: gruas, 
      //     cliente: Jose Ferdando, 
      //     cliente_id: 5, 
      //     nombre_origen: Doble vía la guardias, 
      //     nombre_destino: Distrito 10 Santa Cruz de la Sierra Andrés Ibáñez Province Santa Cruz Department Bolivia, 
      //     descarga: fdsfdsfdsfds, 
      //     referencia: 32165498, 
      //     monto: 50, 
      //     socketClientId: gSb207yjYJ__v9lbAAAD
      
      final payload = data['payload'];

      print(payload['origen']);
      print(payload['destino']);
      print(payload['monto']);

      final arguments = DetalleNotificacionConductor(
        origen: LatLng(payload['origen'][0], payload['origen'][1]),
        destino: LatLng(payload['destino'][0], payload['destino'][1]),
        servicio: payload['servicio'],
        cliente: payload['cliente'],
        clienteId: payload['cliente_id'],
        nombreOrigen: payload['nombre_origen'],
        nombreDestino: payload['nombre_destino'],
        descripcionDescarga: payload['descripcionDescarga'],
        referencia: payload['referencia'],
        monto: double.parse(payload['monto'].toString()),
        socketClientId: payload['socketClientId'],
      );

      navigator.pushNamed('ConductorNotificacion', arguments: arguments);

    });

  }

  void clearSocket(){
    SocketService.off('solicitud pedido conductor');
  }
  
}
