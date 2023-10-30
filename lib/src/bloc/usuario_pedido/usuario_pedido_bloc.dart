import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/global/enviroment.dart';
import 'package:gruasgo/src/models/models.dart';
import 'package:gruasgo/src/models/response/google_map_direction.dart';
import 'package:gruasgo/src/models/response/place_description.dart';
import 'package:gruasgo/src/services/socket_services.dart';
import 'package:http/http.dart' as http;

import 'package:gruasgo/src/models/response/place_response.dart';

import 'package:uuid/uuid.dart';

part 'usuario_pedido_event.dart';
part 'usuario_pedido_state.dart';

typedef ShowAlertCallback = void Function(String message);

class UsuarioPedidoBloc extends Bloc<UsuarioPedidoEvent, UsuarioPedidoState> {
  
  PedidoModel? pedidoModel;
  GoogleMapDirection? googleMapDirection;
  List<PointLatLng>? polylines;
  UserBloc userBloc;

  List<PlaceModel> placeModel = [];

  UsuarioPedidoBloc({
    required this.userBloc
  }) : super(UsuarioPedidoState()) {
    on<OnSetOrigen>((event, emit) {
      emit(state.copyWitch(
        origen: event.origen,
      ));
    });
    on<OnSetDestino>((event, emit) {
      emit(state.copyWitch(
        destino: event.destino,
      ));
    });
    on<OnActualizarContador>((event, emit){
      print('actualizando');
      emit(state.copyWitch(contador: state.contador + event.contador));
    });
    on<OnSetContador>((event, emit){
      emit(state.copyWitch(contador: event.contador));
    });
    on<OnSelected>((event, emit) {
      
      PositionModel position = PositionModel(lat: 0, lng: 0);
      for (var element in placeModel) {
        if (element.name == event.name){
          if (element.position != null){
            position = element.position!;
          }
        }
      }

      if (event.type == 'origen'){
        emit(state.copyWitch(origen: LatLng(position.lat, position.lng)));
      }else{
        emit(state.copyWitch(destino: LatLng(position.lat, position.lng)));
      }
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

  Future<double?> calcularDistancia() async {
      
    try {
      
      // var urlParse = Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${state.destino!.latitude},${state.destino!.longitude}&origins=${state.origen!.latitude},${state.origen!.longitude}&key=${Enviroment().apiKeyGoogleMap}');
      // final resp = await http.post(urlParse);
      // Map<String, dynamic> jsonData = json.decode(resp.body);
      // int distanceValue = jsonData['rows'][0]['elements'][0]['distance']['value'];
      // String distanceString = jsonData['rows'][0]['elements'][0]['distance']['text'];
      
      // print(distanceString);
      // print(distanceValue);

      //   'btip': 'costo',
      //   'bkilometros': '2.0',
      //   'bserv': 'gruas'
      // });

      final data = {
        'lat_origen': state.origen!.latitude,
        'lng_origen': state.origen!.longitude,
        'lat_destino': state.destino!.latitude,
        'lng_destino': state.destino!.longitude,
        'servicio': 'gruas'
      };

      var urlParse = Uri.parse('${Enviroment().server}/map');

      final response = await http.post(
        urlParse, 
        body: jsonEncode(data),       
        headers: {
          'Content-Type': 'application/json'
        }
      );

      Map<String, dynamic> jsonData = json.decode(response.body);
      String distanceValue = jsonData['distancia'];

      const String url = "https://nesasbolivia.com/gruasgo/pedido.php";
      final Uri uri = Uri.parse(url);

      final responsePrecio = await http.post(uri, body: {
        "btip": 'costo',
        "bkilometros": distanceValue,
        "bserv": 'gruas'
      });

      if (responsePrecio.body == '[]'){
        return null;
      }
      List<dynamic> jsonDataPrecio = json.decode(responsePrecio.body);
      String precioData = jsonDataPrecio[0]['costo'];
      
      return double.parse(precioData);
    } catch (e) {
      print(e);
      return null;
    }

  }

  Future<void> getDirecion({
    required LatLng origen,
    required LatLng destino,
  }) async{
    
    const key = 'AIzaSyAM_GlhLkiLrtgBL5G_Pteq1o1I-6C9ljA';
    var urlParce = Uri.parse('https://maps.googleapis.com/maps/api/directions/json?destination=${origen.latitude},${origen.longitude}&origin=${destino.latitude},${destino.longitude}&key=$key');
    final resp = await http.get(urlParce);
    
    if (resp.statusCode == 200){
      googleMapDirection = googleMapDirectionFromJson(resp.body);

      print('-----------------------');
      print(googleMapDirection!.routes[0].bounds.toJson());
      print(googleMapDirection!.routes[0].legs[0].distance.text);
      print(googleMapDirection!.routes[0].legs[0].duration.text);
      polylines = PolylinePoints().decodePolyline(googleMapDirection!.routes[0].overviewPolyline.points);
      // print(googleMapDirection!.routes[0].overviewPolyline.points);
      // print(polylines!.map((e) => LatLng(e.latitude, e.longitude)).toList());

    }

  }


  Future<bool> registrarPedido({
    required idUsuario,
    required String ubiInicial,
    required String ubiFinal,
    required String metodoPago,
    required double monto,
    required String servicio,
    required String descripcionDescarga,
    required int celentrega
  }) async {
    
    const uuid = Uuid();
    final uuidPedido = uuid.v4();

    // try {

      // final response = await ClienteService().registrarPedido(
      //   uuidPedido: uuidPedido, 
      //   idUsuario: idUsuario, 
      //   ubiInicial: ubiInicial, 
      //   ubiFinal: ubiFinal, 
      //   metodoPago: metodoPago, 
      //   monto: monto, 
      //   servicio: servicio, 
      //   descripcionDescarga: 
      //   descripcionDescarga, 
      //   celentrega: celentrega
      // );

      
      // if (response.statusCode != 200) {
      //   print(response.body);
      //   // TODO: Mensaje de error
      //   return false;
      // }

      // dynamic jsonData = json.decode(response.body);
      // if (jsonData['success'] == 'si') {
        
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
          origen: state.origen!, 
          destino: state.destino!
        );
        
        return true;
      // }else{
      //   print(response.body);
      //   return false;
      // }
    
    // } catch (e) {
    //   print(e);
    //   return false;
    // }
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
      print(data);
      navigator.pushNamed('UsuarioPedidoAceptado');
    });
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
