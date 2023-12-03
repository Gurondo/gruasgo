import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/enum/estado_pedido_aceptado_enum.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/enum/polyline_id_enum.dart';
import 'package:gruasgo/src/global/enviroment.dart';
import 'package:gruasgo/src/helpers/get_marker.dart';
import 'package:gruasgo/src/lib/map_icon.dart';
import 'package:gruasgo/src/models/models.dart';
import 'package:gruasgo/src/models/response/google_map_direction.dart' as data;
import 'package:gruasgo/src/models/response/pedido_response.dart';
import 'package:gruasgo/src/models/response/response_pedido_usuario.dart';
import 'package:gruasgo/src/services/http/cliente_service.dart';
import 'package:gruasgo/src/services/http/google_map_services.dart';
import 'package:gruasgo/src/services/socket_services.dart';
import 'package:http/http.dart' as http;

import 'package:audioplayers/audioplayers.dart';


import 'package:gruasgo/src/models/response/place_response.dart';


part 'usuario_pedido_event.dart';
part 'usuario_pedido_state.dart';

typedef ShowAlertCallback = void Function(String message);

class UsuarioPedidoBloc extends Bloc<UsuarioPedidoEvent, UsuarioPedidoState> {
  
  PedidoModel? pedidoModel;
  // List<PointLatLng>? polylines;
  UserBloc userBloc;

  static AudioPlayer player = AudioPlayer();
  
  // Estado Pedido
  var paraOrigen = false;

  List<PlaceModel> placeModel = [];

  UsuarioPedidoBloc({
    required this.userBloc
  }) : super(const UsuarioPedidoState()) {
    
    on<OnSetAddNewMarkets>((event, emit){

      Set<Marker> markers = Set.from(state.markers);

      Marker? marker;

      for (var elementMarker in markers) {
        if (elementMarker.markerId.value == event.marker.markerId.value){
          marker = elementMarker;
          break;
        }
      }
      if (marker != null) markers.remove(marker);
      markers.add(event.marker);
      emit(state.copyWitch(markers: markers));
    });
  
    on<OnDeleteMarkerById>((event, emit){

      Set<Marker> markers = Set.from(state.markers);

      Marker? marker;

      for (var elementMarker in markers) {
        if (elementMarker.markerId.value == event.markerIdEnum.toString()){
          marker = elementMarker;
          break;
        }
      }
      if (marker != null) markers.remove(marker);

      emit(state.copyWitch(markers: markers));
    });

    on<OnSetAddNewPolylines>((event, emit){

      Set<Polyline> polylines = Set.from(state.polylines);

      Polyline? polyline;

      for (var elementPolyline in polylines) {
        if (elementPolyline.polylineId.value == event.polyline.polylineId.value){
          polyline = elementPolyline;
          break;
        }
      }
      if (polyline != null) polylines.remove(polyline);
      polylines.add(event.polyline);
      emit(state.copyWitch(polylines: polylines));
    });

    on<OnSetIdConductor>((event, emit) => emit(state.copyWitch(idConductor: event.idConductor)));

    on<OnUpdateDistanciaDuracion>((event, emit) => emit(state.copyWitch(distancia: event.distancia, duracion: event.duracion)));

    on<OnConductorEstaAqui>((event, emit) => emit(state.copyWitch(conductorEstaAqui: event.conductorEstaAqui)) );

    on<OnRemoveMarker>((event, emit){
      Set<Marker> markers = Set.from(state.markers);
      markers.removeWhere((element) => element.markerId.value == event.id.toString());
      emit(state.copyWitch(markers: markers));
    });

    on<OnClearPolylines>((event, emit){
      emit(state.copyWitch(polylines: {}));
    });

    on<OnSetEstadoPedidoAceptado>((event, emit){
      emit(state.copyWitch(estadoPedidoAceptado: event.estadoPedidoAceptado));
    });
    
  }


  
  void conectarseSocket({required String idUsuario}){
    SocketService.open();
    SocketService.emit('usuario online', {
      'id': int.parse(idUsuario),
    });
  }

  void desconectarseSocket(){
    SocketService.close();
  }

  Future<bool?> buscarPedidoPendiente({
    required int idPedido,
    required String idUsuario
  }) async {

    final resp = await ClienteService.getPedidoPendiente(idPedido: idPedido, idUsuario: idUsuario);

    print(resp.body);
    print(resp.statusCode);


    if (resp.statusCode == 500) {
      add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.sinPedido));
      return false;
    }

    final responsePedidoUsuario = responsePedidoUsuarioFromJson(resp.body);
    if (responsePedidoUsuario.isEmpty) {
      add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.sinPedido));
      return false;
    }

    print(responsePedidoUsuario[0].toJson());

    if (responsePedidoUsuario[0].peEstado == 'APCO'){
      add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.estoyAqui));
    }else if (responsePedidoUsuario[0].peEstado == 'NOCL'){
      add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.comenzarCarrera));
    }else if (responsePedidoUsuario[0].peEstado == 'VICO'){
      add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.finalizarCarrera));
    }else{
      add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.sinPedido));
    }

    if (['NOCL', 'APCO', 'VICO'].contains(responsePedidoUsuario[0].peEstado)){
      add(OnSetIdConductor(responsePedidoUsuario[0].coIdConductor));
      
      pedidoModel = PedidoModel(
        btip: 'addPedido', 
        bidpedido: responsePedidoUsuario[0].peIdPedido, 
        bidusuario: responsePedidoUsuario[0].usIdUsuario, 
        bubinicial: responsePedidoUsuario[0].peUbiInicial, 
        bubfinal: responsePedidoUsuario[0].peUbiFinal, 
        bmetodopago: responsePedidoUsuario[0].peMetodoPago, 
        bmonto: responsePedidoUsuario[0].peMonto, 
        bservicio: responsePedidoUsuario[0].peServicio, 
        bdescarga: responsePedidoUsuario[0].peDescripCarga, 
        bcelentrega: responsePedidoUsuario[0].peCelularEntrega, 
        origen: LatLng(responsePedidoUsuario[0].peIniLat, responsePedidoUsuario[0].peIniLog), 
        destino: LatLng(responsePedidoUsuario[0].peFinalLat, responsePedidoUsuario[0].peFinalLog), 
        conductor: responsePedidoUsuario[0].coNombreConductor,
        placa: responsePedidoUsuario[0].vePlaca
      );

      final LatLng positionConductor = LatLng( double.parse(responsePedidoUsuario[0].cdLatitud.toString()),  double.parse(responsePedidoUsuario[0].cdLongitud.toString()),);

      add(OnSetAddNewMarkets(
        Marker(
          markerId: MarkerId(MarkerIdEnum.conductor.toString()),
          position: positionConductor,
          icon: MapIcons.iconConductor ?? BitmapDescriptor.defaultMarker
        )
      ));

      if (['NOCL', 'APCO'].contains(responsePedidoUsuario[0].peEstado)){

        add(OnSetAddNewMarkets(
          Marker(
            markerId: MarkerId(MarkerIdEnum.origen.toString()),
            icon: MapIcons.iconMarkerOrigen ?? BitmapDescriptor.defaultMarker,
            position: LatLng(responsePedidoUsuario[0].peIniLat, responsePedidoUsuario[0].peIniLog), 
          )
        ));

        final polyline = await getPolylines(origen: positionConductor, destino: LatLng(responsePedidoUsuario[0].peIniLat, responsePedidoUsuario[0].peIniLog), );
        if (polyline != null){
          add(OnSetAddNewPolylines(
            Polyline(
              polylineId: PolylineId(PolylineIdEnum.conductorToOrigen.toString()),
              points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
            )
          ));
        }




        paraOrigen = true;
        return true;
      } else {
        add(OnSetAddNewMarkets(
          Marker(
            markerId: MarkerId(MarkerIdEnum.destino.toString()),
            icon: MapIcons.iconMarkerDestino ?? BitmapDescriptor.defaultMarker,
            position: LatLng(responsePedidoUsuario[0].peFinalLat, responsePedidoUsuario[0].peFinalLog), 
          )
        ));

        final polyline = await getPolylines(origen: positionConductor, destino: LatLng(responsePedidoUsuario[0].peFinalLat, responsePedidoUsuario[0].peFinalLog));
        if (polyline != null){
          add(OnSetAddNewPolylines(
            Polyline(
              polylineId: PolylineId(PolylineIdEnum.conductorToDestino.toString()),
              points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
            )
          ));
        }

        paraOrigen = false;
        return true;
      }


      
    }else{


      // TODO: Borrar el id del local storage

    }

    return false;

  }

  Future<String?> searchPlaceByCoors({required LatLng coors}) async {

    var urlParse = Uri.parse('${Enviroment().server}/map/searchPlaceByCoors?lat=${coors.latitude}&&lng=${coors.longitude}');

    // try {
      
      final response = await http.get(
        urlParse, 
        headers: {
          'Content-Type': 'application/json'
        }
      );
      
      final responseEncode = jsonDecode(response.body);
      
      return responseEncode['place'];
           
    // } catch (e) {
    //   print(e);
    //   return null;
    // }

  }

  Future<List<String>> searchPlace({required String place}) async {

    var urlParse = Uri.parse('${Enviroment().server}/map/search?place=$place');

    // try {
      
      final response = await http.get(
        urlParse, 
        headers: {
          'Content-Type': 'application/json'
        }
      );
      
      List<String> placesName = [];

      if (place.isNotEmpty) {
        final placesResponse = placesResponseFromJson(response.body);
        placeModel = placesResponse.places;
        for (var element in placesResponse.places) {
          if (element.name != null){
            placesName.add(element.name!);
          }
        }
      } 

      // return names;
      return placesName;

    // } catch (e) {
    //   print(e);
    //   return [];  
    // }

  }

  Future<bool> getPedido({required int idPedido}) async {

    final response = await ClienteService.getPedido(idPedido: idPedido);
    print(response.body);
    final responsePedido = responsePedidoFromJson(response.body)[0];

    pedidoModel!.bmonto = responsePedido.monto;

    return true;
  }

  Future<int?> calcularPrecioPorHora({
    required String servicio
  }) async{
    
    // try {
      
      final responsePrecio = await ClienteService.getPrecioHoras(servicio: servicio);
      
      var jsonData1 = json.decode(responsePrecio.body);
      
      return jsonData1["costo"];

    // } catch (e) {
    //   print(e);
    //   return -1;
    // }

  }

  Future<int?> calcularPrecioDistancia({
    required String servicio
  }) async {
      
    // try {

      // Obtener el origen y el destino de mi lista de Markers
      Marker? origen = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.origen);
      Marker? destino = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.destino);

      if (origen == null || destino == null){
        return null;
      }

      // Hacer consulta para obtener la distancia entre dos puntos
      final responseDistancia = await GoogleMapServices.getDistancia(origen: origen.position, destino: destino.position, servicio: servicio);

      Map<String, dynamic> jsonData = json.decode(responseDistancia.body);
      String distanciaValue = jsonData['distancia'];

      // Consultar para obtener el costo
      final responsePrecio = await ClienteService.getPrecioKilometro(distancia: distanciaValue.toString(), servicio: servicio);
      
      var jsonData1 = json.decode(responsePrecio.body);
      
      if (jsonData1["costo"] == null) return null;

      return jsonData1["costo"];
    // } catch (e) {
    //   print(e);
    //   return null;
    // }

    
    

  }

  Future<List<PointLatLng>?> getPolylines({
    required LatLng origen,
    required LatLng destino,
  }) async{

    final resp = await GoogleMapServices.googleDirections( origen: origen, destino: destino);
    
    if (resp.statusCode == 200){
      final googleMapDirection = data.googleMapDirectionFromJson(resp.body);
      return PolylinePoints().decodePolyline(googleMapDirection.routes[0].overviewPolyline.points);
    }
    return null;

  }

  Future<bool> sendEventDistanciaDuracion({
    required LatLng origen,
    required LatLng destino,
  }) async {

    final resp = await GoogleMapServices.googleDirections( origen: origen, destino: destino);
    
    if (resp.statusCode == 200){
      final googleMapDirection = data.googleMapDirectionFromJson(resp.body);
      add(OnUpdateDistanciaDuracion(
        distancia: googleMapDirection.routes[0].legs[0].distance.text, 
        duracion: googleMapDirection.routes[0].legs[0].duration.text
      ));
      return true;
    }
    return false;

  }

  bool guardarPedido({
    required idUsuario,
    required String ubiInicial,
    required String ubiFinal,
    required String metodoPago,
    required int monto,
    required String servicio,
    required String descripcionDescarga,
    required int celentrega,
    required Marker origen,
    required Marker destino,
  }){
    pedidoModel = PedidoModel(
      btip: 'addPedido', 
      bidpedido: -1, 
      bidusuario: idUsuario, 
      bubinicial: ubiInicial, 
      bubfinal: ubiFinal, 
      bmetodopago: metodoPago, 
      bmonto: monto, 
      bservicio: servicio, 
      bdescarga: descripcionDescarga, 
      bcelentrega: celentrega, 
      origen: origen.position, 
      destino: destino.position
    );

    return true;

  }

  Future<bool> registrarPedido({
    required idUsuario,
    required String ubiInicial,
    required String ubiFinal,
    required String metodoPago,
    required int monto,
    required String servicio,
    required String descripcionDescarga,
    required int celentrega
  }) async {
    
    // try {

      Marker? origen = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.origen);
      Marker? destino = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.destino);

      if (origen == null || destino == null) return false;
      

      final idResponse = await ClienteService.getId();
      dynamic jsonDataId = json.decode(idResponse.body);
      final id = jsonDataId[0]['genId'];

    
      print('Este es el id del pedido');
      print(id);
      final response = await ClienteService.registrarPedido(
        uuidPedido: id, 
        idUsuario: idUsuario, 
        ubiInicial: ubiInicial, 
        ubiFinal: ubiFinal, 
        metodoPago: metodoPago, 
        monto: monto, 
        descripcionDescarga: 
        descripcionDescarga, 
        celentrega: celentrega,
        servicio: servicio, 
        ubiInitLat: origen.position.latitude,
        ubiInitLog: origen.position.longitude,
        ubiFinLat: destino.position.latitude,
        ubiFinLog: destino.position.longitude
      );
      print('creando un nuevo pedido');
      print(response.body);
      if (response.statusCode != 200) return false;
      
      dynamic jsonData = json.decode(response.body);
      if (jsonData['success'] == 'si') {
        
        // Cuando se registre, poner el id al id del pedido, ya que antes estaba con 0
        pedidoModel!.bidpedido = id;

        return true;
      }else{
        return false;
      }
    
    // } catch (e) {
    //   print(e);
    //   return false;
    // }
  }

  // Socket
  void solicitar({
    required String servicio,
    required int pedidoId,
    required String nombreUsuario,
    required String clienteid,
    required LatLng origen,
    required LatLng destino,
  }){
    
    print('===================================');
    print(pedidoId);
    SocketService.emit('solicitar', {
      'servicio': servicio,
      'cliente': nombreUsuario,
      'idCliente': int.parse(clienteid),
      'idPedido': pedidoId,
      'origen': origen,
      'destino': destino
    });

  }

  Future<bool> cancelarPedido() async {

    // try {
      SocketService.emit('cancelar pedido cliente', {
        'idPedido': pedidoModel!.bidpedido
      });

      final response = await ClienteService.cancelarEstadoPedido(uuidPedido: pedidoModel!.bidpedido);
      print(response.body);


      return response.statusCode == 200;

    // } catch (e) {
    //   print(e);
    //   return false;
    // }

  }

  Future<bool> cancelarPedidoEnProceso() async {

    final response = await ClienteService.cancelarEstadoPedido(uuidPedido: pedidoModel!.bidpedido);
    print(response.body);

    return response.statusCode == 200;
    
  }

  void emitPedidoCanceladoEnProceso(){

    print('a este conductor se le notificara que este pedido a sido cancelado');
    print(state.idConductor);
    SocketService.emit('pedido CACL cancelado cliente', {
      'idConductor': state.idConductor
    });
  }

  void respuesta({required ShowAlertCallback showAlert}){
    SocketService.on('respuesta solicitud usuario', (data) {
      print(data);
      // final status = data['ok'];
      // if (!status){
      //   showAlert(data['msg']);
      // }
    });

  }

  // TODO: Borrar
  void actualizarContador(){
    SocketService.on('actualizar contador', (data){
      if (data['isReset']){
        add(OnSetContador(data['contador']));
      }else{
        add(OnActualizarContador(data['contador']));
      }
    });
  }
  

  void listenPedidoAceptado({required NavigatorState navigator}) {
    SocketService.on('pedido aceptado por conductor', (data) async {

      pedidoModel!.conductor = data['nombreConductor'];
      pedidoModel!.placa = data['placa'];

      add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.estoyAqui));

      add(OnSetIdConductor(data['id']));

      add(OnSetAddNewMarkets(
        Marker(markerId: MarkerId(MarkerIdEnum.destino.toString()))
      ));

      add(OnSetAddNewMarkets(
        Marker(
          markerId: MarkerId(MarkerIdEnum.conductor.toString()),
          position: LatLng(data['lat'], data['lng']),
          icon: MapIcons.iconConductor ?? BitmapDescriptor.defaultMarker
        )
      ));



      // TODO: Aqui comenzar a dibujar
      add(OnClearPolylines());
      Marker? origen = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.origen);
      paraOrigen = true;
      if (origen != null){
        final polyline = await getPolylines(origen: LatLng(data['lat'], data['lng']), destino: origen.position);

        if (polyline != null){
          add(OnSetAddNewPolylines(
            Polyline(
              polylineId: PolylineId(PolylineIdEnum.conductorToOrigen.toString()),
              color: Colors.black,
              width: 4,
              points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
            )
          ));
        }
      }



      navigator.pop();
      
      
      // final polylines = await getPolylines(origen: origen, destino: destino);

    });
  }

  void listenPosicionConductor(){
    SocketService.on('actualizar posicion conductor', (data) async {
      // TODO: Aqui actualizar la posicion del conductor
            
      print('La nueva posicion es');
      print('${data['lat']}, ${data['lng']}');
      add(OnSetAddNewMarkets(
        Marker(
          markerId: MarkerId(MarkerIdEnum.conductor.toString()),
          position: LatLng(data['lat'], data['lng']),
          icon: MapIcons.iconConductor ?? BitmapDescriptor.defaultMarker,
          // rotation: data['rotation'] ?? 0.0
        )
      ));


      if (paraOrigen){
        Marker? origen = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.origen);
        if (origen != null){
          final polyline = await getPolylines(origen: LatLng(data['lat'], data['lng']), destino: origen.position);
          if (polyline != null){
            add(OnSetAddNewPolylines(
              Polyline(
                polylineId: PolylineId(PolylineIdEnum.conductorToOrigen.toString()),
                color: Colors.black,
                width: 4,
                points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
              )
            ));
          }
        }
      }else{
        Marker? destino = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.destino);
        if (destino != null){
          final polyline = await getPolylines(origen: LatLng(data['lat'], data['lng']), destino: destino.position);
          if (polyline != null){
            add(OnSetAddNewPolylines(
              Polyline(
                polylineId: PolylineId(PolylineIdEnum.conductorToDestino.toString()),
                color: Colors.black,
                width: 4,
                points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
              )
            ));
          }
        }
      }


      // add(OnSetPositionConductor(LatLng(data['lat'], data['lng'])));
      // print(data);
    });
  }

  void listenConductorEstaAqui(){
    SocketService.on('El conductor ya esta aqui', (data) async {
      add(OnConductorEstaAqui(true));

      add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.comenzarCarrera));
      // Reproducir el sonido
      audio();
    });
  }

  Future audio() async {
    await player.setSource(AssetSource('sonido/sonido.mp3'));
    await player.resume();
    Future.delayed(const Duration(seconds: 2), () {
      player.stop();
    });
  }

  void listenPedidoProcesoCancelado({
    required NavigatorState navigator,
    required String nombreUsuario
  }){    
    SocketService.on('pedido en proceso cancelado', (data){
      add(OnClearPolylines());
      add(OnSetIdConductor(-1));
      add(OnDeleteMarkerById(MarkerIdEnum.conductor));
      navigator.pushNamedAndRemoveUntil('bienbendioUsuario', (route) => false, arguments: nombreUsuario);
    });
  }

  void listenPedidoFinalizado({required NavigatorState navigator}){
    SocketService.on('pedido finalizado', (data){

      add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.sinPedido));
      add(OnClearPolylines());
      final minutos = data['minutos'] ?? '';
      navigator.pushNamedAndRemoveUntil('UsuarioFinalizacion', (route) => false, arguments: minutos);
    });
  }

  void listenComenzarCarrera(){
    SocketService.on('El conductor comenzo carrera', (data) async {

      add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.finalizarCarrera));

      add(OnRemoveMarker(MarkerIdEnum.origen));
      add(OnClearPolylines());

      add(OnSetAddNewMarkets(
        Marker(
          markerId: MarkerId(MarkerIdEnum.destino.toString()),
          position: pedidoModel!.destino,
          icon: MapIcons.iconMarkerDestino ?? BitmapDescriptor.defaultMarker
        )
      ));
      
      paraOrigen = false;
      Marker? conductor = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.conductor);
      if (conductor != null){
        final polyline = await getPolylines(origen: conductor.position, destino: pedidoModel!.destino);
        if (polyline != null){
          add(OnSetAddNewPolylines(
            Polyline(
              polylineId: PolylineId(PolylineIdEnum.conductorToDestino.toString()),
              color: Colors.black,
              width: 4,
              points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
            )
          ));
        }
      }


    });
  }

  void clearSocketComenzarCarrera(){
    SocketService.off('El conductor comenzo carrera');
  }

  void clearSocketPedidoFinalizado(){
    SocketService.off('pedido finalizado');
  }

  void clearSocketConductorEstaAqui(){
    SocketService.off('El conductor ya esta aqui');
  }

  void clearSocketPedidoProcesadoCancelado(){
    SocketService.off('pedido en proceso cancelado');
  }

  void clearSocketPosicionConductor(){
    SocketService.off('actualizar posicion conductor');
  }

  void clearSocketActualizarContador(){
    SocketService.off('actualizar contador');
  }

  void clearSocketRespuestaUsuario(){
    SocketService.off('respuesta solicitud usuario');
  }

  void clearSocketIsSuccessPedido(){
    SocketService.off('pedido aceptado por conductor');
  }
}
