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
  
    print('bidpedido: ${idString.substring(idString.length - 6)}');
    print('bidusuario : $idUsuario');
    print('bubinicial: $ubiInicial');
    print('bubfinal: $ubiFinal');
    print('metodoPago: $metodoPago');
    print('bmonto: $monto');
    print('bservicio: $servicio');
    print('bdescarga: $descripcionDescarga');
    print('bcelentrega: $celentrega');
    print('bubinilat: $ubiInitLat');
    print('bubinilog: $ubiInitLog');
    print('bubfinlat: $ubiFinLat');
    print('bubfinlog: $ubiFinLog');

    final response = await http.post(uri, body: {
      'btip': 'addPedido',
      'bidpedido': idString.substring(idString.length - 6),
      'bidusuario': idUsuario,
      'bidvehiculo': '',
      'bidconductor': '',
      'bubinicial': ubiInicial,
      'bubinilat': ubiInitLat.toString(),
      'bubinilog': ubiInitLog.toString(),
      'bubfinal': ubiFinal,
      'bubfinlat': ubiFinLat.toString(),
      'bubfinlog': ubiFinLog.toString(),
      'bestado': "SOCL",
      'bmetodopago': metodoPago,
      'bmonto': monto.toString(),
      'bservicio': servicio,
      'bdescarga': descripcionDescarga,
      'bcelentrega': celentrega.toString()
    });

    return response;

  }

  static Future<http.Response> getPrecio ({
    required String distancia,
    required String servicio
  }) async{
    
    print('---------------LO QUE SE ENVIA PARA OBTENER EL PRECIO--------------------------');
    print("bkilometros: $distancia");
    print("bserv: $servicio");
    print('--------------------------------------------------------');

    final String url = "${Enviroment().baseUrl}/pedido.php";
    final Uri uri = Uri.parse(url);

    final response = await http.post(uri, body: {
      "btip": 'costo',
      "bkilometros": distancia.toString(),
      "bserv": servicio
    });

    return response;
    
  }

}