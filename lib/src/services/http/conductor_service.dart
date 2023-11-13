import 'package:gruasgo/src/global/enviroment.dart';
import 'package:http/http.dart' as http;

class ConductorService{

  ConductorService._();

  static Future<http.Response> crearEstado({
    required String idConductor,
    required double lat,
    required double lng,
  }) async {
    var urlParce = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'ADD_ES',
      'bidconductor': idConductor,
      'bublatitud': lat.toString(),
      'bublongitud': lng.toString(),
      'bestado': 'ES'
    });

    return resp;
  }

  static Future<http.Response> obtenerEstadoConPedido({required String idConductor}) async{
    var urlParce = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'BUCON',
      'bidconductor': idConductor
    });

    return resp;
  }

  static Future obtenerEstado({required String idConductor}) async{
    var urlParce = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'BUSEST',
      'bidconductor': idConductor
    });

    var urlParce1 = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    final resp1 = await http.post(urlParce, body: {
      'btip': 'BUES',
    });
    print('----------------aqui esta todo-----------------------');
    print(resp1.body);
    return resp;
  }

  static Future<http.Response> actualizarEstadoAceptado({
    required String idConductor,
    required String idPedido,
  }) async{
    var urlParce = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    
    final resp = await http.post(urlParce, body: {
      'btip': 'UPESPE',
      'bidconductor': idConductor,
      'bidpedido': idPedido,
      'bestado': 'PE'
    });

    return resp;
  }

  static Future<http.Response> adicionarHora({
    required String idPedido
  }) async {
    
    final String url = "${Enviroment().baseUrl}/pedido.php";
    final Uri uri = Uri.parse(url);

    final response = await http.post(uri, body: {
      'btip': 'addHoraini',
      'bidpedido': idPedido,
    });

    return response;
  }
    
  static Future<http.Response> actualizarEstadoEnPedido({
    required String idPedido,
    required String idVehiculo,
    required String idConductor,
    required String estado
  }) async {
    final String url = "${Enviroment().baseUrl}/pedido.php";
    final Uri uri = Uri.parse(url);

    final response = await http.post(uri, body: {
      'btip': 'AcpCanConductor',
      'bidpedido': idPedido,
      'bidvehiculo': idVehiculo,
      'bidconductor': idConductor,
      'bestado': estado
    });

    return response;
  }

  static Future actualizarUbicacionEstado({
    required String idConductor,
    required double ubiLatitud,
    required double ubiLongitud
  }) async{
    var urlParce = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'UPUB',
      'bidconductor': idConductor,
      'bublatitud': ubiLatitud.toString(),
      'bublongitud': ubiLongitud.toString()
    });
    return resp;
  }

  static Future eliminarEstado({
    required String idConductor
  }) async{
    var urlParce = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'DEL',
      'bidconductor': idConductor,
    });
    return resp;
  }

  static Future<http.Response> getPedido({
    required String idPedido
  }) async {
    var urlParce = Uri.parse('${Enviroment().baseUrl}/pedido.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'devPedido',
      'bidpedido': idPedido,
    });
    return resp;
  }

  static Future<http.Response> getMinutosConsumidos({
    required String idPedido
  }) async {
    var urlParce = Uri.parse('${Enviroment().baseUrl}/pedido.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'devuelveMinutos',
      'bidpedido': idPedido,
    });
    return resp;
  }

}