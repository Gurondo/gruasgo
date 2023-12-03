
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/arguments/detalle_notificacion_conductor.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/bloc/usuario_pedido/usuario_pedido_bloc.dart';
import 'package:gruasgo/src/enum/estado_pedido_aceptado_enum.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/enum/polyline_id_enum.dart';
import 'package:gruasgo/src/helpers/helpers.dart';
import 'package:gruasgo/src/lib/map_icon.dart';
import 'package:gruasgo/src/models/response/estado_pedido_response.dart';
import 'package:gruasgo/src/models/response/estado_response.dart';
import 'package:gruasgo/src/models/response/google_map_direction.dart' as polyline;
import 'package:gruasgo/src/models/response/pedido_response.dart';
import 'package:gruasgo/src/services/http/cliente_service.dart';
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

  static AudioPlayer player = AudioPlayer();


  bool notificacionPedidoCanceladoCliente = false;

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

    on<OnSetEstadoPedidoAceptado>((event, emit){
      emit(state.copyWitch(estadoPedidoAceptado: event.estadoPedidoAceptado));
    });
    
    on<OnSetTiempoTranscurrido>((event, emit){
      if (state.detallePedido != null){
        DetalleNotificacionConductor? detalle = DetalleNotificacionConductor(
          origen: state.detallePedido!.origen, 
          destino: state.detallePedido!.destino, 
          servicio: state.detallePedido!.servicio, 
          cliente: state.detallePedido!.cliente, 
          clienteId: state.detallePedido!.clienteId, 
          nombreOrigen: state.detallePedido!.nombreOrigen, 
          nombreDestino: state.detallePedido!.nombreDestino, 
          descripcionDescarga: state.detallePedido!.descripcionDescarga, 
          referencia: state.detallePedido!.referencia, 
          monto: state.detallePedido!.monto, 
          socketClientId: state.detallePedido!.socketClientId, 
          pedidoId: state.detallePedido!.pedidoId, 
          estado: state.detallePedido!.estado,
          tiempoTranscurrido: event.tiempoTranscurrido,
          tipoPago: state.detallePedido!.tipoPago
        );

        emit(state.copyWitch(detallePedido: detalle));
      }


    });

    on<OnSetRemoveMarker>((event, emit){
      Set<Marker> markers = Set.from(state.markers);
      markers.removeWhere((marker) => marker.markerId.value == event.id.toString());
      emit(state.copyWitch(markers: markers));
    });
    
  }



  Future<bool> eliminarCrearEstado({
    required int idUsuario,
    required String servicio
  }) async {
    try {
      
      await ConductorService.eliminarEstado(idConductor: idUsuario);
      Position position = await getPositionHelpers();
      await ConductorService.crearEstado(
        idConductor: idUsuario, 
        lat: position.latitude, 
        lng: position.longitude,
        servicio: servicio
      );
      
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> adiccionarHora({
    required int idPedido
  }) async {

    final Response resp = await ConductorService.adicionarHora(idPedido: idPedido);

    print('Adiccionar hora');
    print(resp.body);
    return resp.statusCode == 200;
  }

  Future<bool> actualizarCoorEstado({
    required int idUsuario
  }) async {
    try {
      
      final Position position = await getPositionHelpers();

      Response resp = await ConductorService.actualizarUbicacionEstado(
        idConductor: idUsuario, 
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

  Future<int?> getMinutosConsumidos({
    required int idPedido
  }) async {
    Response resp = await ConductorService.getMinutosConsumidos(idPedido: idPedido);

    print(resp.body);
    if (resp.statusCode != 200) return null;
    dynamic jsonData = json.decode(resp.body);
    
    return jsonData[0]['minutos'];
  }

  Future<bool> eliminarEstado({
    required int idUsuario
  }) async {

    try {
      
      Response resp = await ConductorService.eliminarEstado(idConductor: idUsuario);
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

  Future<bool> buscarEstado({
    required int idUsuario,
    required String subServicio
  }) async{

    // try {
      
      final Response respEstado = await ConductorService.obtenerEstado(
        idConductor: idUsuario
      );
      print('Obtener Estado');
      print(respEstado.body);
      if (respEstado.statusCode != 200) return false;
      
      final responseEstado = responseEstadoFromJson(respEstado.body);
      if (responseEstado.isEmpty) return true;


      if (responseEstado[0].estado == 'PE'){
        
        final Response resp = await ConductorService.obtenerEstadoConPedido(
          idConductor: idUsuario,
          subServicio: subServicio
        );

        if (resp.statusCode != 200) return false;

        print('Obtener Estado Pedido');
        print(subServicio);
        print(resp.body);
        final responseEstadoPedido = responseEstadoPedidoFromJson(resp.body);
        
        if (responseEstadoPedido.isEmpty || responseEstadoPedido[0].the16 == 'CACL') return false;

        final data = responseEstadoPedido[0];

        if (data.horaIni != null){
          add(OnSetDetallePedido(DetalleNotificacionConductor(
            origen: LatLng(data.iniLat, data.iniLog),
            destino: LatLng(data.finalLat, data.finalLog),
            servicio: data.servicio,
            cliente: "nombre del usuario",
            clienteId: data.idUsuario,
            nombreOrigen: data.ubiInicial,
            nombreDestino: data.ubiFinal,
            descripcionDescarga: data.descripCarga,
            referencia: data.celularEntrega,
            monto: data.monto,
            socketClientId: 'socket_id',
            pedidoId: data.idPedido,
            estado: data.estado,
            horaFin: data.horaFin,
            horaInicio: data.horaIni,
            tipoPago: data.metodoPago
          )));
        }else{
          add(OnSetDetallePedido(DetalleNotificacionConductor(
            origen: LatLng(data.iniLat, data.iniLog),
            destino: LatLng(data.finalLat, data.finalLog),
            servicio: data.servicio,
            cliente: "nombre del usuario",
            clienteId: data.idUsuario,
            nombreOrigen: data.ubiInicial,
            nombreDestino: data.ubiFinal,
            descripcionDescarga: data.descripCarga,
            referencia: data.celularEntrega,
            monto: data.monto,
            socketClientId: 'socket_id',
            pedidoId: data.idPedido,
            estado: data.estado,
            tipoPago: data.metodoPago
          )));
        }



        // add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum));
        Marker origen = (data.estado != 'VICO') ? Marker(
          markerId: MarkerId(MarkerIdEnum.origen.toString()),
          position: LatLng(data.iniLat, data.iniLog),
          icon: MapIcons.iconMarkerOrigen ?? BitmapDescriptor.defaultMarker
        ) : Marker(
          markerId: MarkerId(MarkerIdEnum.origen.toString())
        );


        
        Marker destino = (data.estado == 'VICO') ? Marker(
          markerId: MarkerId(MarkerIdEnum.destino.toString()),
          position: LatLng(data.finalLat, data.finalLog),
          icon: MapIcons.iconMarkerDestino ?? BitmapDescriptor.defaultMarker
        ) : Marker(
          markerId: MarkerId(MarkerIdEnum.destino.toString())
        );


        add(OnSetNewMarkets({
          origen,
          destino,
        }));


        final position = await getPositionHelpers();
        openSocket(
          idUsuario: idUsuario,
          servicio: userBloc.user!.subCategoria
        );
        print(data.estado);
        List<PointLatLng>? polyline;
        if (data.estado == 'VICO'){
          polyline = await getPolylines(
            origen: LatLng(position.latitude, position.longitude), 
            destino: LatLng(data.finalLat, data.finalLog),
          );
          add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.finalizarCarrera));
        }else if(data.estado == 'NOCL'){
          add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.comenzarCarrera));
        } else {
          polyline = await getPolylines(
            origen: LatLng(position.latitude, position.longitude), 
            destino: LatLng(data.iniLat, data.iniLog),
          );
          add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.estoyAqui));
        }


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
        await eliminarEstado(idUsuario: idUsuario);
      }

      return true;

    // } catch (e) {
    //   print(e);
    //   return false;
    // }
  }

  Future<bool> crearEstado({
    required int idUsuario,
    required String servicio
  }) async {

    try {
      
      Position position = await getPositionHelpers();

      final Response resp = await ConductorService.crearEstado(
        idConductor: idUsuario, 
        lat: position.latitude, 
        lng: position.longitude,
        servicio: servicio
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
    
    if (destino.latitude == 0 && destino.longitude == 0) return null;

    if (resp.statusCode == 200){
      final googleMapDirection = polyline.googleMapDirectionFromJson(resp.body);
      return PolylinePoints().decodePolyline(googleMapDirection.routes[0].overviewPolyline.points);
    }
    return null;

  }

  Future<bool> actualizarPedido({
    required int idConductor,
    required int idPedido,
    required String idVehiculo,
    required String estado
  })async{
    final responsePedido = await ConductorService.actualizarEstadoEnPedido(
      idPedido: idPedido, 
      idVehiculo: idVehiculo,
      idConductor: idConductor, 
      estado: estado
    );

    print('Actualizando estado del pedido en $estado');
    print(responsePedido.body);
    return responsePedido.statusCode == 200;
  }

  Future<bool> pedidoNoAceptado({
    required int idConductor,
    required int idPedido,
    required String idVehiculo
  }) async {

    try {

      final responsePedido = await ConductorService.actualizarEstadoEnPedido(
        idPedido: idPedido, 
        idVehiculo: idVehiculo,
        idConductor: idConductor, 
        estado: 'RECO'
      );
      print('Cambiando el estado que rechazo el pedido RECO');
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
    required int idConductor,
    required int idPedido,
    required String placa
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
        idVehiculo: placa, 
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

  Future<bool> updatePrecioTotal({
    required int idPedido,
    required int monto
  }) async {

    final responsePrecioPedido = await ConductorService.updateMontoTotal(
      idPedido: idPedido,
      monto: monto
    );

    print('Guardando el precio total en horas');
    print(monto);
    print(responsePrecioPedido.body);
    if (responsePrecioPedido.statusCode != 200) return false;

    return true;

  }

  void openSocket({
    required int idUsuario,
    required String servicio
  }) {
    SocketService.open();

    SocketService.emit('usuario online', {
      'id': idUsuario,
      'servicio': servicio
    });

  }

  void closeSocket() {
    SocketService.close();
  }

  void updatePosition({required lat, required lng}){
    print('enviando coordenadas al usuario');

    if (state.detallePedido != null){
      SocketService.emit('actualizar coordenadas conductor', {
        'lat': lat,
        'lng': lng,
        'idCliente': state.detallePedido?.clienteId ?? ''
      });
    }


  }

  void emitComenzarCarrera(){

    SocketService.emit('comenzar carrera', {
      'idCliente': state.detallePedido!.clienteId
    });
  }

  void emitFinalizarPedido({
    int? minutos
  }){
    SocketService.emit('finalizar pedido', {
      'idCliente': state.detallePedido!.clienteId,
      'minutos': minutos
    });
  }
  
  void emitYaEstoyAqui(){
    SocketService.emit('ya estoy aqui', {
      'idCliente': state.detallePedido!.clienteId,
    });
  }

  void emitRespuestaPedidoProcesoCancelado(){
    SocketService.emit('pedido proceso cancelado conductor', {
      'idCliente': state.detallePedido!.clienteId,
    });
  }

  void respuestaPedido({
    required bool pedidoAceptado,
    required LatLng origen,
    required LatLng destino,
    required String servicio,
    required String cliente,
    required int clienteId,
    required int pedidoId,
    required String nombreConductor,
    required String placa

  }) async {

    Position position = await getPositionHelpers();

    SocketService.emit('respuesta del conductor', {
      'pedidoAceptado': pedidoAceptado,
      'origen': origen, 
      'destino': destino,
      'servicio': servicio,
      'cliente': cliente,
      'idCliente': clienteId,
      'idPedido': pedidoId,
      'lat': position.latitude,
      'lng': position.longitude,
      'nombreConductor': nombreConductor,
      'placa': placa
    });

  }

  void notificacionNuevaSolicitudConductor({
    required NavigatorState navigator,
    required int idConductor
  }){

    SocketService.on('notificacion pedido conductor', (data) async {
      
      final payload = data['payload'];
      print(data);
      final response = await ConductorService.getPedido(idPedido: payload['idPedido']);

      print(response.body);

      if (response.statusCode != 200){
        print('No se pudo obtener el pedido');
      } else{
        final responsePedido = responsePedidoFromJson(response.body)[0];

        detallePedido = DetalleNotificacionConductor(
          origen: LatLng(responsePedido.iniLat, responsePedido.iniLog),
          destino: LatLng(responsePedido.finalLat, responsePedido.finalLog),
          servicio: responsePedido.servicio,
          cliente: payload['cliente'],
          clienteId: responsePedido.idUsuario,
          nombreOrigen: responsePedido.ubiInicial,
          nombreDestino: responsePedido.ubiFinal,
          descripcionDescarga: responsePedido.descripCarga,
          referencia: responsePedido.celularEntrega,
          monto: responsePedido.monto,
          // TODO: BorrarSOcket
          socketClientId: payload['socket_client_id'],
          pedidoId: responsePedido.idPedido,
          estado: responsePedido.estado,
          tipoPago: responsePedido.metodoPago
        );

        print(detallePedido.toString());

        add(OnSetNewMarkets({
          Marker(
            markerId: MarkerId(MarkerIdEnum.origen.toString()),
            position: detallePedido!.origen,
            icon: MapIcons.iconMarkerOrigen ?? BitmapDescriptor.defaultMarker
          ),
          Marker(
            markerId: MarkerId(MarkerIdEnum.destino.toString()),
            position: detallePedido!.destino,
            icon: MapIcons.iconMarkerDestino ?? BitmapDescriptor.defaultMarker
          ),
        }));

        audio();

       
        navigator.pushNamed('ConductorNotificacion');
      }
      // TODO: Aqui quiero obtener el pedido mandando el id del pedido
      



    });

  }

  Future audio() async {
    await player.setSource(AssetSource('sonido/sonido.mp3'));
    await player.resume();
    Future.delayed(const Duration(seconds: 2), () {
      player.stop();
    });
  }

  void solicitudYaTomada(){

    SocketService.on('pedido ya tomado', (data){
      print('La solicitud ya ha sido tomada');
    });

  }

  void listenPedidoCanceladoCliente({required NavigatorState navigator}){
    SocketService.on('pedido cancelado desde cliente', (data) {

      // ClienteService.cancelarEstadoPedido(uuidPedido: detallePedido!.pedidoId);
      print('Aqui a cancelado un cliente');
      notificacionPedidoCanceladoCliente = true;

      navigator.pop();
    });
  }

  void listenNotificacionPedidoCancelado({
    required NavigatorState navigator
  }){
    SocketService.on('pedido CACL cancelado', (data){


      add(OnSetLimpiarPedidos());

      navigator.pushNamedAndRemoveUntil('bienbenidoConductor', (route) => false);

    });
  }

  void clearPedidoCanceladoClienteSocket(){
    SocketService.off('pedido cancelado desde cliente');
  }

  void clearSolicitudYaTomadaSocket(){
    SocketService.off('pedido ya tomado');
  }

  void clearSocketNotificacionNuevaSolicitudConductor(){
    SocketService.off('notificacion pedido conductor');
  }
  
  void clearSocketNotificacionPedidoCancelado(){
    SocketService.off('pedido CACL cancelado');
  }
  
}
