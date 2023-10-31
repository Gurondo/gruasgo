
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/arguments/detalle_notificacion_conductor.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/helpers/helpers.dart';
import 'package:gruasgo/src/models/response/estado_response.dart';
import 'package:gruasgo/src/models/response/google_map_direction.dart';
import 'package:gruasgo/src/services/http/conductor_service.dart';
import 'package:gruasgo/src/services/http/google_map_services.dart';
import 'package:gruasgo/src/services/socket_services.dart';

import 'package:equatable/equatable.dart';
import 'package:http/http.dart';

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
    
    on<OnSetTiempo>((event, emit) {
      emit(state.copyWitch(tiempo: event.tiempo));
    });
  }

  Future<bool> actualizarCoorEstado() async {
    try {
      
      final Position position = await getPositionHelpers();

      Response resp = await ConductorService().actualizarUbicacionEstado(
        idConductor: userBloc.user!.idUsuario, 
        ubiLatitud: position.latitude, 
        ubiLongitud: position.longitude
      );
      
      print('actualizando');
      print(resp.body);
      
      dynamic jsonData = json.decode(resp.body);
      if (jsonData['success'] != 'si') return false;
      
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> eliminarEstado() async {

    try {
      
      Response resp = await ConductorService().eliminarEstado(idConductor: userBloc.user!.idUsuario);
      print('eliminar estado');
      print(resp.body);
      if (resp.statusCode != 200) return false;
      
      dynamic jsonData = json.decode(resp.body);
      if (jsonData['success'] != 'si') return false;
      
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> buscarEstado() async{

    try {
      
      final Response resp = await ConductorService().obtenerEstado(idConductor: userBloc.user!.idUsuario);
      print('buscar estado');
      print(resp.body);
      if (resp.statusCode != 200) return false;
      
      final responseEstado = responseEstadoFromJson(resp.body);

      
      if (responseEstado.isEmpty) return true;
      
      final status = await eliminarEstado();
      return status;

    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> crearEstado() async {

    try {
      
      Position position = await getPositionHelpers();

      final Response resp = await ConductorService().agregarEstado(
        idConductor: userBloc.user!.idUsuario, 
        lat: position.latitude, 
        lng: position.longitude
      );
      print('crear estado');
      print(resp.body);
      if (resp.statusCode != 200) {
        return false;
      }


      return true;
    } catch (e) {
      print(e);
      return false;
    }
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

  void respuestaPedido({required DetalleNotificacionConductor detalleNotificacionConductor, required bool pedidoAceptado}){

    // SocketService.emit('cancelar pedido', detalleNotificacionConductor);
    SocketService.emit('respuesta del conductor', {
      'pedido_aceptado': pedidoAceptado,
      'origen': detalleNotificacionConductor.origen, 
      'destino': detalleNotificacionConductor.destino,
      'servicio': detalleNotificacionConductor.servicio,
      'cliente': detalleNotificacionConductor.cliente,
      'cliente_id': detalleNotificacionConductor.clienteId,
      'nombre_origen': detalleNotificacionConductor.nombreOrigen,
      'nombre_destino': detalleNotificacionConductor.nombreDestino,
      'descripcion_descarga': detalleNotificacionConductor.descripcionDescarga,
      'referencia': detalleNotificacionConductor.referencia,
      'monto': detalleNotificacionConductor.monto,
      'socket_client_id': detalleNotificacionConductor.socketClientId
    });

  }

  // void aceptarPedido({required String socketClientId, required String clientId}){

  //   SocketService.emit('aceptar pedido', {
  //     'socket_client_id': socketClientId,
  //     'client_id': clientId
  //   });

  // }

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

      final arguments = DetalleNotificacionConductor(
        origen: LatLng(payload['origen'][0], payload['origen'][1]),
        destino: LatLng(payload['destino'][0], payload['destino'][1]),
        servicio: payload['servicio'],
        cliente: payload['cliente'],
        clienteId: payload['cliente_id'],
        nombreOrigen: payload['nombre_origen'],
        nombreDestino: payload['nombre_destino'],
        descripcionDescarga: payload['descripcion_descarga'],
        referencia: payload['referencia'],
        monto: double.parse(payload['monto'].toString()),
        socketClientId: payload['socket_client_id'],
      );

      navigator.pushNamed('ConductorNotificacion', arguments: arguments);

    });

  }

  void solicitudCancelada({required NavigatorState navigator}){
    SocketService.on('solicitud cancelada', (data){
      navigator.pop();
      // TODO: Aqui tiene que poner, el cliente a cancelado el pedido
    });
  }

  void clearSolicitudCanceladaSocket(){
    SocketService.off('solicitud cancelada');
  }

  void clearSocketSolicitudConductor(){
    SocketService.off('solicitud pedido conductor');
  }
  
}
