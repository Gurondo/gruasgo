import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/global/enviroment.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'usuario_pedido_event.dart';
part 'usuario_pedido_state.dart';


class UsuarioPedidoBloc extends Bloc<UsuarioPedidoEvent, UsuarioPedidoState> {
  UsuarioPedidoBloc() : super(UsuarioPedidoState()) {
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
  }

  Future<String> searchPlace({required String place}) async {

    var urlParse = Uri.parse('${Enviroment().server}/map/search?place=$place');

    try {
      
      final response = await http.get(
        urlParse, 
        headers: {
          'Content-Type': 'application/json'
        }
      );
      
      print(response.body);
      
      return '';

    } catch (e) {
      print(e);
      return '';  
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

  Future<bool> registrarPedido({
    required idPedido,
    required idUsuario,
    required ubiInicial,
    required ubiFinal,
    required metodoPago,
    required monto,
    required servicio,
    required descarga,
    required entrega
  }) async {
    
    final String url = "${Enviroment().baseUrl}/pedidos.php";
    final Uri uri = Uri.parse(url);

    try {

      final response = await http.post(uri, body: {
        "btip": '',
        "bidpedido": idPedido,
        "bidusuario": idUsuario,
        "bubinicial": ubiInicial,
        "bubfinal": ubiFinal,
        "bmetodopago": metodoPago,
        "bmonto": monto,
        "bservicio": servicio,
        "bdescarga": descarga,
        "bcelentrega": entrega
      });

      if (response.statusCode != 200) {
        // TODO: Mensaje de error
        return true;
      }

      return true;
    
    } catch (e) {
      print(e);
      return false;
    }
  }
}
