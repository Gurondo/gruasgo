import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/enum/polyline_id_enum.dart';
import 'package:gruasgo/src/global/enviroment.dart';
import 'package:gruasgo/src/helpers/get_marker.dart';
import 'package:gruasgo/src/models/models.dart';
import 'package:gruasgo/src/models/response/google_map_direction.dart' as data;
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
    
    on<OnActualizarContador>((event, emit){
      print('actualizando');
      emit(state.copyWitch(contador: state.contador + event.contador));
    });
    
    on<OnSetContador>((event, emit){
      emit(state.copyWitch(contador: event.contador));
    });

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

    
  }


  
  void conectarseSocket({required String idUsuario}){
    SocketService.open();
    SocketService.emit('usuario online', {
      'id': idUsuario,
    });
  }

    void desconectarseSocket(){
    SocketService.close();
  }


  Future<String?> searchPlaceByCoors({required LatLng coors}) async {

    var urlParse = Uri.parse('${Enviroment().server}/map/searchPlaceByCoors?lat=${coors.latitude}&&lng=${coors.longitude}');

    try {
      
      final response = await http.get(
        urlParse, 
        headers: {
          'Content-Type': 'application/json'
        }
      );
      
      final responseEncode = jsonDecode(response.body);
      
      return responseEncode['place'];
           
    } catch (e) {
      print(e);
      return null;
    }

  }

  Future<List<String>> searchPlace({required String place}) async {

    var urlParse = Uri.parse('${Enviroment().server}/map/search?place=$place');

    try {
      
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

    } catch (e) {
      print(e);
      return [];  
    }

  }

  Future getPedido({required String idPedido}) async {

    final response = await ClienteService.getPedido(idPedido: idPedido);
    print(response.body);

  }

  Future<String?> calcularPrecioPorHora({
    required String servicio
  }) async{
    
    try {
      
      final responsePrecio = await ClienteService.getPrecioHoras(servicio: servicio);
      
      var jsonData1 = json.decode(responsePrecio.body);
      
      return jsonData1["costo"].toString();

    } catch (e) {
      print(e);
      return '';
    }

  }

  Future<String?> calcularPrecioDistancia({
    required String servicio
  }) async {
      
    try {

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

      return jsonData1["costo"].toString();
    } catch (e) {
      print(e);
      return null;
    }

    
    

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
    required String monto,
    required String servicio,
    required String descripcionDescarga,
    required int celentrega,
    required Marker origen,
    required Marker destino,
  }){
    pedidoModel = PedidoModel(
      btip: 'addPedido', 
      bidpedido: '-1', 
      bidusuario: idUsuario.toString(), 
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
    required String monto,
    required String servicio,
    required String descripcionDescarga,
    required int celentrega
  }) async {
    
    try {

      Marker? origen = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.origen);
      Marker? destino = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.destino);

      if (origen == null || destino == null) return false;
      

      final idResponse = await ClienteService.getId();
      dynamic jsonDataId = json.decode(idResponse.body);
      final id = jsonDataId[0]['genId'];



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
    
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Socket
  void solicitar({
    required String servicio,
    required String pedidoId,
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
      'idCliente': clienteid,
      'idPedido': pedidoId,
      'origen': origen,
      'destino': destino
    });

  }

  Future<bool> cancelarPedido() async {

    try {
      SocketService.emit('cancelar pedido cliente', {
        'idPedido': pedidoModel!.bidpedido
      });

      final response = await ClienteService.cancelarEstadoPedido(uuidPedido: pedidoModel!.bidpedido);
      print(response.body);

      return response.statusCode == 200;

    } catch (e) {
      print(e);
      return false;
    }

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
  

  Future<BitmapDescriptor>? createMarkerImageFromAsset(String path) async{
    ImageConfiguration configuration = const ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }
  void listenPedidoAceptado({required NavigatorState navigator}) {
    SocketService.on('pedido aceptado por conductor', (data) async {
      add(OnSetIdConductor(data['id']));
      final markerDriver = await createMarkerImageFromAsset('assets/img/icon_truc.png');
      add(OnSetAddNewMarkets(
        Marker(
          markerId: MarkerId(MarkerIdEnum.conductor.toString()),
          position: LatLng(data['lat'], data['lng']),
          icon: markerDriver!,
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
      
      Marker? marker = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.conductor);

      
      print('La nueva posicion es');
      print('${data['lat']}, ${data['lng']}');
      add(OnSetAddNewMarkets(
        Marker(
          markerId: MarkerId(MarkerIdEnum.conductor.toString()),
          position: LatLng(data['lat'], data['lng']),
          icon: marker?.icon ?? BitmapDescriptor.defaultMarker,
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
      add(OnSetIdConductor(''));
      add(OnDeleteMarkerById(MarkerIdEnum.conductor));
      navigator.pushNamedAndRemoveUntil('bienbendioUsuario', (route) => false, arguments: nombreUsuario);
    });
  }

  void listenPedidoFinalizado({required NavigatorState navigator}){
    SocketService.on('pedido finalizado', (data){
      add(OnClearPolylines());
      navigator.pushNamedAndRemoveUntil('UsuarioFinalizacion', (route) => false);
    });
  }

  void listenComenzarCarrera(){
    SocketService.on('El conductor comenzo carrera', (data) async {
      add(OnRemoveMarker(MarkerIdEnum.origen));
      add(OnClearPolylines());
      
      paraOrigen = false;
      Marker? destino = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.destino);
      Marker? conductor = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.conductor);
      if (destino != null && conductor != null){
        final polyline = await getPolylines(origen: conductor.position, destino: destino.position);
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
