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
    required int celentrega,
    required double ubiInitLat,
    required double ubiInitLog,
    required double ubiFinLat,
    required double ubiFinLog,
  }) async{

    final String url = "${Enviroment().baseUrl}/pedido.php";
    final Uri uri = Uri.parse(url);

    print(uuidPedido);
    print(idUsuario);
    print(ubiInicial);
    print(ubiFinal);
    print(metodoPago);
    print(monto);
    print(servicio);
    print(descripcionDescarga);
    print(celentrega);
    print(ubiInitLat);
    print(ubiInitLog);
    print(ubiFinLat);
    print(ubiFinLog);

    final response = await http.post(uri, body: {
      "btip": 'addPedido',
      "bidpedido": uuidPedido,
      "bidusuario": idUsuario,
      "bidvehiculo": "",
      "bidconductor": "",
      "bubinicial": ubiInicial,
      "bubinilat": ubiInitLat.toString(),
      "bubinilog": ubiInitLog.toString(),
      "bubfinal": ubiFinal,
      "bubfinlat": ubiFinLat.toString(),
      "bubfinlog": ubiFinLog.toString(),
      "bbestado": "SOCL",
      "bmetodopago": metodoPago,
      "bmonto": monto.toString(),
      "bservicio": servicio,
      "bdescarga": descripcionDescarga,
      "bcelentrega": celentrega.toString()
    });

    return response;

  }

}