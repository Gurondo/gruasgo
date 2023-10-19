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

  Future<double?> calcularDistancia() async {
      
    try {

      var urlParse = Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${state.destino!.latitude},${state.destino!.longitude}&origins=${state.origen!.latitude},${state.origen!.longitude}&key=${Enviroment().apiKeyGoogleMap}');
      final resp = await http.post(urlParse);
      Map<String, dynamic> jsonData = json.decode(resp.body);
      int distanceValue = jsonData['rows'][0]['elements'][0]['distance']['value'];
      String distanceString = jsonData['rows'][0]['elements'][0]['distance']['text'];
      
      print(distanceString);
      print(distanceValue);
      
      // TODO: Aqui debo consultar para obtener el precio mediante su distancia, y retornar el precio total
      
      return 0.0;
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
