import 'package:gruasgo/src/global/enviroment.dart';
import 'package:http/http.dart' as http;

class ClienteService{

  ClienteService._();

  static Future registrarPedido({
    required int uuidPedido,
    required String idUsuario,
    required String ubiInicial,
    required String ubiFinal,
    required String metodoPago,
    required int monto,
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

    final response = await http.post(uri, body: {
      'btip': 'addPedido',
      'bidpedido': uuidPedido.toString(),
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

  static Future<http.Response> cancelarEstadoPedido({
    required int uuidPedido
  }) async {
    final String url = "${Enviroment().baseUrl}/pedido.php";
    final Uri uri = Uri.parse(url);

    final response = await http.post(uri, body: {
      'btip': 'updEstado',
      'bidpedido': uuidPedido.toString(),
      'bestado': "CACL",
    });

    return response;
  }

  static Future<http.Response> getPrecioHoras({
    required String servicio
  }) async{
    final String url = "${Enviroment().baseUrl}/pedido.php";
    final Uri uri = Uri.parse(url);

    final response = await http.post(uri, body: {
      "btip": 'costo',
      "bminutos": "60",
      "bserv": servicio
    });
    
    print(response.body);
    return response;
  }

  static Future<http.Response> getPrecioKilometro ({
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
      // "bminutos": "60",
      "bserv": servicio
    });

    return response;
    
  }

  static Future<http.Response> getId () async{
    
    final String url = "${Enviroment().baseUrl}/pedido.php";
    final Uri uri = Uri.parse(url);

    final response = await http.post(uri, body: {
      "btip": 'genId',
    });

    return response;
    
  }
  
  static Future<http.Response> getPedido({
    required int idPedido
  }) async {
    var urlParce = Uri.parse('${Enviroment().baseUrl}/pedido.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'devPedido',
      'bidpedido': idPedido.toString(),
    });
    return resp;
  }


  // Para buscar el pedido
  static Future<http.Response> getPedidoPendiente({
    required int idPedido,
    required String idUsuario
  }) async {

    var urlParce = Uri.parse('${Enviroment().baseUrl}/pedido.php');

    final resp = await http.post(urlParce, body: {
      'btip': 'BUCONPedido',
      'bidpedido': idPedido.toString(),
      'bidusuario': idUsuario
    });

    return resp;

  }
}