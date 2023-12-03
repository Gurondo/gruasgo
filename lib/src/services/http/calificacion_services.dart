import 'package:gruasgo/src/global/enviroment.dart';

import 'package:http/http.dart' as http;

class CalificacionService{

  CalificacionService._();

  static Future<http.Response> guardarCalificacion({
    required int idPedido,
    required String puntaje,
    required String tipoUsuario,
    required String observaciones

  }) async {
    final String url = "${Enviroment().baseUrl}/pedido.php";
    final Uri uri = Uri.parse(url);

    final response = await http.post(uri, body: {
      'btip': 'addCalificacion',
      'bidpedido': idPedido,
      'bpuntaje': puntaje,
      'btipusu': tipoUsuario,
      'bobservaciones': observaciones,
    });

    return response;
  }

}