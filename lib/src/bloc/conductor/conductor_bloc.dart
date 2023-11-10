
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/arguments/detalle_notificacion_conductor.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/enum/polyline_id_enum.dart';
import 'package:gruasgo/src/helpers/helpers.dart';
import 'package:gruasgo/src/models/response/estado_pedido_response.dart';
import 'package:gruasgo/src/models/response/estado_response.dart';
import 'package:gruasgo/src/models/response/google_map_direction.dart' as polyline;
import 'package:gruasgo/src/services/http/conductor_service.dart';
import 'package:gruasgo/src/services/http/google_map_services.dart';
import 'package:gruasgo/src/services/socket_services.dart';

import 'package:equatable/equatable.dart';
import 'package:http/http.dart';

part 'conductor_event.dart';
part 'conductor_state.dart';

class ConductorBloc extends Bloc<ConductorEvent, ConductorState> {

  UserBloc userBloc;
  DetalleNotificacionConductor? detallePedido;

  bool yaHayPedido = false;

  ConductorBloc({
    required this.userBloc
  }) : super(const ConductorState()) {
    on<ConductorEvent>((event, emit) {
      // TODO: implement event handler
    });
    
    on<OnSetTiempo>((event, emit) {
      emit(state.copyWitch(tiempo: event.tiempo));
    });

    on<OnSetDetallePedido>((event, emit){
      emit(state.copyWitch(detallePedido: event.detallePedido));
    });

    on<OnSetNewMarkets>((event, emit){
      Set<Marker> markers = event.markets;
      emit(state.copyWitch(markers: markers));
    });


    on<OnSetAddMarker>((event, emit) {

      Set<Marker> markers = Set.from(state.markers);
      Marker? marker;
  
      for (var elementMarkers in markers) {
        if (elementMarkers.markerId.value == event.marker.markerId.value){
          marker = elementMarkers;
        }
      }

      if (marker != null) markers.remove(marker);

      markers.add(event.marker);

      emit(state.copyWitch(markers: markers));
    });

    on<OnSetAddPolyline>((event, emit) {

      Set<Polyline> polylines = Set.from(state.polylines);

      Polyline? polyline;
  
      for (var elementPolyline in polylines) {
        if (elementPolyline.polylineId.value == event.polyline.polylineId.value){
          polyline = elementPolyline;
        }
      }

      if (polyline != null) polylines.remove(polyline);

      polylines.add(event.polyline);

      emit(state.copyWitch(polylines: polylines));
    });

    on<OnSetLimpiarPedidos>((event, emit){
      emit(state.copyWitch(polylines: {}, markers: {}, detallePedido: null));
    });

    on<OnSetClearPolylines>((event, emit){
      emit(state.copyWitch(polylines: {}));
    });
  }

  Future<bool> eliminarCrearEstado() async {
    try {
      
      await ConductorService.eliminarEstado(idConductor: userBloc.user!.idUsuario);
      Position position = await getPositionHelpers();
      await ConductorService.crearEstado(idConductor: userBloc.user!.idUsuario, lat: position.latitude, lng: position.longitude);
      
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> actualizarCoorEstado() async {
    try {
      
      final Position position = await getPositionHelpers();

      Response resp = await ConductorService.actualizarUbicacionEstado(
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
      
      Response resp = await ConductorService.eliminarEstado(idConductor: userBloc.user!.idUsuario);
      if (resp.statusCode != 200) return false;
      print('Actualizando para elimianr este estado');
      print(resp.body);
      dynamic jsonData = json.decode(resp.body);
      return jsonData['success'] == 'si';
      
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> buscarEstado() async{

    try {
      
      final Response respEstado = await ConductorService.obtenerEstado(
        idConductor: userBloc.user!.idUsuario
      );
      print('Obtener Estado');
      print(respEstado.body);
      if (respEstado.statusCode != 200) return false;
      
      final responseEstado = responseEstadoFromJson(respEstado.body);
      if (responseEstado.isEmpty) return true;

      if (responseEstado[0].estado == 'PE'){
        
        final Response resp = await ConductorService.obtenerEstadoConPedido(idConductor: userBloc.user!.idUsuario);
        if (resp.statusCode != 200) return false;

        print('Obtener Estado Pedido');
        print(resp.body);
        final responseEstadoPedido = responseEstadoPedidoFromJson(resp.body);
        
        if (responseEstadoPedido.isEmpty) return true;

        final data = responseEstadoPedido[0];
        add(OnSetDetallePedido(DetalleNotificacionConductor(
          origen: LatLng(double.parse(data.iniLat), double.parse(data.iniLog)),
          destino: LatLng(double.parse(data.finalLat), double.parse(data.finalLog)),
          servicio: data.servicio,
          cliente: "nombre del usuario",
          clienteId: data.idUsuario,
          nombreOrigen: data.ubiInicial,
          nombreDestino: data.ubiFinal,
          descripcionDescarga: data.descripCarga,
          referencia: int.parse(data.celularEntrega),
          monto: double.parse(data.monto),
          socketClientId: 'socket_id',
          pedidoId: data.idPedido
        )));

        add(OnSetNewMarkets({
          Marker(
            markerId: MarkerId(MarkerIdEnum.origen.toString()),
            position: LatLng(double.parse(data.iniLat), double.parse(data.iniLog)),
          ),
          Marker(
            markerId: MarkerId(MarkerIdEnum.destino.toString()),
            position: LatLng(double.parse(data.finalLat), double.parse(data.finalLog)),
          ),
        }));

        print(state.detallePedido);

        final position = await getPositionHelpers();
        openSocket(
          lat: position.latitude, 
          lng: position.longitude
        );
        
        List<PointLatLng>? polyline = await getPolylines(
          origen: LatLng(position.latitude, position.longitude), 
          destino: LatLng(double.parse(data.iniLat), double.parse(data.iniLog)),
        );

        if (polyline != null){

          add(OnSetAddPolyline(
            Polyline(
              polylineId: PolylineId(PolylineIdEnum.posicionToOrigen.toString()),
              color: Colors.black,
              width: 4,
              points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
            )
          ));
        }

        yaHayPedido = true;

      }else{
        await eliminarEstado();
      }

      return true;

    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> crearEstado() async {

    try {
      
      Position position = await getPositionHelpers();

      final Response resp = await ConductorService.crearEstado(
        idConductor: userBloc.user!.idUsuario, 
        lat: position.latitude, 
        lng: position.longitude
      );

      print('Crear estado');
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
    
    final resp = await GoogleMapServices.googleDirections( origen: origen, destino: destino);
    
    if (resp.statusCode == 200){
      final googleMapDirection = polyline.googleMapDirectionFromJson(resp.body);
      return PolylinePoints().decodePolyline(googleMapDirection.routes[0].overviewPolyline.points);
    }
    return null;

  }

  Future<bool> pedidoNoAceptado({
    required String idConductor,
    required String idPedido
  }) async {

    try {

      final responsePedido = await ConductorService.actualizarEstadoEnPedido(
        idPedido: idPedido, 
        idVehiculo: '-', 
        idConductor: idConductor, 
        estado: 'RECO'
      );
      print('Cambiando el estado que rechazo el pedido');
      print(responsePedido.body);
      if (responsePedido.statusCode != 200) return false;
      dynamic jsonDataPedido = json.decode(responsePedido.body);
      return (jsonDataPedido['success'] == 'si');

    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> pedidoAceptado({
    required String idConductor,
    required String idPedido
  }) async {
    try {
      
      final responseStatus = await ConductorService.actualizarEstadoAceptado(
        idConductor: idConductor, 
        idPedido: idPedido
      );

      print('Cambiando el estado que acepto');
      print(responseStatus.body);
      if (responseStatus.statusCode != 200) return false;
      dynamic jsonData = json.decode(responseStatus.body);
      if (jsonData['success'] != 'si') return false;

      final responsePedido = await ConductorService.actualizarEstadoEnPedido(
        idPedido: idPedido, 
        idVehiculo: '-', 
        idConductor: idConductor, 
        estado: 'APCO'
      );
      print('Cambiando el estado que acepto el pedido');
      print(responsePedido.body);
      if (responsePedido.statusCode != 200) return false;
      dynamic jsonDataPedido = json.decode(responsePedido.body);
      return (jsonDataPedido['success'] == 'si');

    } catch (e) {
      print(e);
      return false;
    }

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

  void respuestaPedidoProcesoCancelado(){
    SocketService.emit('pedido proceso cancelado conductor', {
      'origen': state.detallePedido!.origen, 
      'destino': state.detallePedido!.destino, 
      'servicio': state.detallePedido!.servicio,
      'cliente': state.detallePedido!.cliente,
      'cliente_id': state.detallePedido!.clienteId,
      'nombre_origen': state.detallePedido!.nombreOrigen,
      'nombre_destino': state.detallePedido!.nombreDestino,
      'descripcion_descarga': state.detallePedido!.descripcionDescarga,
      'referencia': state.detallePedido!.referencia,
      'monto': state.detallePedido!.monto,
      'socket_client_id': state.detallePedido!.socketClientId,
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


  void notificacionNuevaSolicitudConductor({required NavigatorState navigator}){

    SocketService.on('notificacion pedido conductor', (data){
    
      final payload = data['payload'];

      detallePedido = DetalleNotificacionConductor(
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
        pedidoId: payload['pedido_id'],
      );;

      add(OnSetNewMarkets({
        Marker(
          markerId: MarkerId(MarkerIdEnum.origen.toString()),
          position: detallePedido!.origen
        ),
        Marker(
          markerId: MarkerId(MarkerIdEnum.destino.toString()),
          position: detallePedido!.destino
        ),
      }));

      navigator.pushNamed('ConductorNotificacion');

    });

  }

  void solicitudYaTomada(){

    SocketService.on('pedido ya tomado', (data){
      print('La solicitud ya ha sido tomada');
    });

  }


  void solicitudCancelada({required NavigatorState navigator}){
    SocketService.on('solicitud cancelada', (data){
      navigator.pop();
      // TODO: Aqui tiene que poner, el cliente a cancelado el pedido
    });
  }

  void clearSolicitudYaTomadaSocket(){
    SocketService.off('pedido ya tomado');
  }

  void clearSolicitudCanceladaSocket(){
    SocketService.off('solicitud cancelada');
  }

  void clearSocketNotificacionNuevaSolicitudConductor(){
    SocketService.off('notificacion pedido conductor');
  }
  
}
