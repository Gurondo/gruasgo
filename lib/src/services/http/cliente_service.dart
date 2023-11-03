import 'package:gruasgo/src/global/enviroment.dart';
import 'package:http/http.dart' as http;

class ClienteService{

  Future registrarPedido({
    required String uuidPedido,
    required String idUsuario,
    required String ubiInicial,
    required String ubiFinal,
    required String metodoPago,
    required double monto,
    required String servicio,
    required String descripcionDescarga,
    required int celentrega
  }) async{

    final String url = "${Enviroment().baseUrl}/pedido.php";
    final Uri uri = Uri.parse(url);

    final response = await http.post(uri, body: {
      "btip": 'addPedido',
      "bidpedido": uuidPedido,
      "bidusuario": idUsuario,
      "bubinicial": ubiInicial,
      "bubfinal": ubiFinal,
      "bbestado": '-',
      "bmetodopago": metodoPago,
      "bmonto": monto.toString(),
      "bservicio": servicio,
      "bdescarga": descripcionDescarga,
      "bcelentrega": celentrega.toString()
    });

    return response;

  }

}