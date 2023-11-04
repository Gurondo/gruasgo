import 'package:gruasgo/src/global/enviroment.dart';
import 'package:http/http.dart' as http;

class ClienteService{

  ClienteService._();

  static Future registrarPedido({
    required String uuidPedido,
    required String idUsuario,
    required String ubiInicial,
    required String ubiFinal,
    required String metodoPago,
    required String monto,
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

    int timestampInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    String idString = timestampInMilliseconds.toString();
  
    print(idString.substring(idString.length - 6));
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
      "btip": idString.substring(idString.length - 6),
      "bidpedido": '123',
      "bidusuario": idUsuario,
      "bidvehiculo": "",
      "bidconductor": "",
      "bubinicial": ubiInicial,
      "bubinilat": ubiInitLat.toString(),
      "bubinilog": ubiInitLog.toString(),
      "bubfinal": ubiFinal,
      "bubfinlat": ubiFinLat.toString(),
      "bubfinlog": ubiFinLog.toString(),
      "bestado": "SOCL",
      "bmetodopago": metodoPago,
      "bmonto": monto.toString(),
      "bservicio": servicio,
      "bdescarga": descripcionDescarga,
      "bcelentrega": celentrega.toString()
    });

    return response;

  }

  static Future<http.Response> getPrecio ({
    required String distancia,
    required String detalleServicio
  }) async{

    final String url = '${Enviroment().apiKeyGoogleMap}/pedido.php';
    final Uri uri = Uri.parse(url);

    final response = await http.post(uri, body: {
      "btip": 'costo',
      "bkilometros": distancia.toString(),
      "bserv": detalleServicio
    });

    return response;
    
  }

}