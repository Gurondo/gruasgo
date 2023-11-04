import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/enum/polyline_id_enum.dart';
import 'package:gruasgo/src/global/enviroment.dart';
import 'package:gruasgo/src/helpers/get_marker.dart';
import 'package:gruasgo/src/models/models.dart';
import 'package:gruasgo/src/models/response/google_map_direction.dart' as data;
import 'package:gruasgo/src/models/response/place_description.dart';
import 'package:gruasgo/src/services/http/cliente_service.dart';
import 'package:gruasgo/src/services/http/google_map_services.dart';
import 'package:gruasgo/src/services/socket_services.dart';
import 'package:http/http.dart' as http;



import 'package:gruasgo/src/models/response/place_response.dart';

import 'package:uuid/uuid.dart';

part 'usuario_pedido_event.dart';
part 'usuario_pedido_state.dart';

typedef ShowAlertCallback = void Function(String message);

class UsuarioPedidoBloc extends Bloc<UsuarioPedidoEvent, UsuarioPedidoState> {
  
  PedidoModel? pedidoModel;
  // List<PointLatLng>? polylines;
  UserBloc userBloc;

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

    on<OnSetIdConductor>((event, emit){
      emit(state.copyWitch(idConductor: event.idConductor));
    });

    on<OnUpdateDistanciaDuracion>((event, emit){
      emit(state.copyWitch(distancia: event.distancia, duracion: event.duracion));
    });


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
      
      var place = '';
      final placesDescriptionResponse = placesDescriptionResponseFromJson(response.body);
      for (var element in placesDescriptionResponse.place) {
        if (!element.types.contains('plus_code')){
          place = '$place ${element.longName}';
        }
      }
      
      return place;
           
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

      final placesResponse = placesResponseFromJson(response.body);
      placeModel = placesResponse.places;
      for (var element in placesResponse.places) {
        if (element.name != null){
          placesName.add(element.name!);
        }
      }
      // return names;
      return placesName;

    } catch (e) {
      print(e);
      return [];  
    }

  }

  Future<String?> calcularDistancia({
    required String servicio
  }) async {
      
    try {

      // Obtener el origen y el destino de mi lista de Markers
      Marker? origen = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.origen);
      Marker? destino = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.destino);

      if (origen == null || destino == null){
        return '';
      }

      // Hacer consulta para obtener la distancia entre dos puntos
      final responseDistancia = await GoogleMapServices.getDistancia(origen: origen.position, destino: destino.position, servicio: servicio);

      print(responseDistancia.body);
      Map<String, dynamic> jsonData = json.decode(responseDistancia.body);
      String distanciaValue = jsonData['distancia'];

      // Consultar para obtener el costo
      final responsePrecio = await ClienteService.getPrecio(distancia: distanciaValue.toString(), servicio: servicio);
      
      print('--------RESPUESTA DESPUES DE LA CONSULTA PARA OBTENER EL PRECIO EN JSON--------');
      print(responsePrecio.body);
      print('----------------');
      var jsonData1 = json.decode(responsePrecio.body);
      

      print('--------RESPUESTA DEL RESULTADO--------');
      print(jsonData1);
      print('----------------');

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

  // Future<void> getDirecion({
  //   required LatLng origen,
  //   required LatLng destino,
  // }) async{
    
  //   const key = 'AIzaSyAM_GlhLkiLrtgBL5G_Pteq1o1I-6C9ljA';
  //   var urlParce = Uri.parse('https://maps.googleapis.com/maps/api/directions/json?destination=${origen.latitude},${origen.longitude}&origin=${destino.latitude},${destino.longitude}&key=$key');
  //   final resp = await http.get(urlParce);
    
  //   if (resp.statusCode == 200){
  //     googleMapDirection = googleMapDirectionFromJson(resp.body);

  //     print('-----------------------');
  //     print(googleMapDirection!.routes[0].bounds.toJson());
  //     print(googleMapDirection!.routes[0].legs[0].distance.text);
  //     print(googleMapDirection!.routes[0].legs[0].duration.text);
  //     polylines = PolylinePoints().decodePolyline(googleMapDirection!.routes[0].overviewPolyline.points);
  //     // print(googleMapDirection!.routes[0].overviewPolyline.points);
  //     // print(polylines!.map((e) => LatLng(e.latitude, e.longitude)).toList());

  //   }

  // }


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
    
    const uuid = Uuid();
    final uuidPedido = uuid.v4();
  
    try {

      Marker? origen = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.origen);
      Marker? destino = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.destino);

      if (origen == null || destino == null) return false;
      

      final response = await ClienteService.registrarPedido(
        uuidPedido: uuidPedido, 
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

      
      
      print('Respuesta despues de registrar el pedido ${response.body}');
      if (response.statusCode != 200) return false;
      

      dynamic jsonData = json.decode(response.body);
      if (jsonData['success'] == 'si') {
        
        pedidoModel = PedidoModel(
          btip: 'addPedido', 
          bidpedido: uuidPedido, 
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
        sendEventDistanciaDuracion(origen: origen.position, destino: destino.position);

        final polyline = await getPolylines(origen: origen.position, destino: destino.position);
        if (polyline != null){
          add(OnSetAddNewPolylines(
            Polyline(
              polylineId: PolylineId(PolylineIdEnum.origenToDestino.toString()),
              color: Colors.black,
              width: 4,
              points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
            )
          ));
        }

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
    required LatLng origen, 
    required LatLng destino, 
    required String servicio,
    required String nombreOrigen,
    required String nombreDestino,
    required String descripcionDescarga,
    required int referencia,
    required double monto
  }){

    SocketService.open();
    SocketService.emit('solicitar', {
      'origen': origen, 
      'destino': destino,
      'servicio': servicio,
      'cliente': userBloc.user!.nombreusuario,
      'cliente_id': userBloc.user!.idUsuario,
      'nombre_origen': nombreOrigen,
      'nombre_destino': nombreDestino,
      'descripcion_descarga': descripcionDescarga,
      'referencia': referencia,
      'monto': monto
    });

  }

  void cancelarPedido(){

    SocketService.emit('cancelar pedido cliente', {
      'cliente_id': userBloc.user!.idUsuario
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

  void actualizarContador(){
    SocketService.on('actualizar contador', (data){
      if (data['isReset']){
        add(OnSetContador(data['contador']));
      }else{
        add(OnActualizarContador(data['contador']));
      }
    });
  }

  void listenPedidoAceptado({required NavigatorState navigator}){
    SocketService.on('pedido aceptado por conductor', (data){
      add(OnSetIdConductor(data['id']));

      add(OnSetAddNewMarkets(
        Marker(
          markerId: MarkerId(MarkerIdEnum.conductor.toString()),
          position: LatLng(data['lat'], data['lng'])
        )
      ));
      navigator.pop();
      print(data['id']);
      
    });
  }

  void listenPosicionConductor(){
    SocketService.on('actualizar posicion conductor', (data){
      // TODO: Aqui actualizar la posicion del conductor

      add(OnSetAddNewMarkets(
        Marker(
          markerId: MarkerId(MarkerIdEnum.conductor.toString()),
          position: LatLng(data['lat'], data['lng'])
        )
      ));

      // add(OnSetPositionConductor(LatLng(data['lat'], data['lng'])));
      // print(data);
    });
  }

  void listenPedidoProcesoCancelado(){
    SocketService.on('pedido en proceso cancelado', (data){
      print('Pedido cancelado por el conductor');
      add(OnSetIdConductor(''));
      add(OnDeleteMarkerById(MarkerIdEnum.conductor));
    });
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
