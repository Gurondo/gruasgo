import 'package:gruasgo/src/global/enviroment.dart';
import 'package:http/http.dart' as http;

class ConductorService{

  ConductorService._();

  static Future<http.Response> crearEstado({
    required int idConductor,
    required double lat,
    required double lng,
    required String servicio
  }) async {
    var urlParce = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'ADD_ES',
      'bidconductor': idConductor,
      'bublatitud': lat.toString(),
      'bublongitud': lng.toString(),
      'bestado': 'ES',
      'bsubservicio': servicio
    });

    return resp;
  }

  static Future<http.Response> getPrecioHoras({
    required String servicio,
    int minutos = 60
  }) async{
    final String url = "${Enviroment().baseUrl}/pedido.php";
    final Uri uri = Uri.parse(url);

    final response = await http.post(uri, body: {
      "btip": 'costo',
      "bminutos": minutos.toString(),
      "bserv": servicio
    });
    
    print(response.body);
    return response;
  }

  static Future<http.Response> obtenerEstadoConPedido({required int idConductor, required String subServicio}) async{
    var urlParce = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'BUCON',
      'bidconductor': idConductor.toString(),
      'bsubservicio': subServicio
    });

    return resp;
  }

  static Future obtenerEstado({required int idConductor}) async{
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
    required int idConductor,
    required int idPedido,
  }) async{
    var urlParce = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    
    final resp = await http.post(urlParce, body: {
      'btip': 'UPESPE',
      'bidconductor': idConductor.toString(),
      'bidpedido': idPedido.toString(),
      'bestado': 'PE'
    });

    return resp;
  }

  static Future<http.Response> adicionarHora({
    required int idPedido
  }) async {
    
    final String url = "${Enviroment().baseUrl}/pedido.php";
    final Uri uri = Uri.parse(url);

    final response = await http.post(uri, body: {
      'btip': 'addHoraini',
      'bidpedido': idPedido.toString(),
    });

    return response;
  }
    
  static Future<http.Response> actualizarEstadoEnPedido({
    required int idPedido,
    required String idVehiculo,
    required int idConductor,
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
    required int idConductor,
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
    required int idConductor
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
    required int idPedido
  }) async {
    var urlParce = Uri.parse('${Enviroment().baseUrl}/pedido.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'devuelveMinutos',
      'bidpedido': idPedido.toString(),
    });
    return resp;
  }


  static Future<http.Response> updateMontoTotal({
    required int idPedido,
    required int monto
  }) async {
    var urlParce = Uri.parse('${Enviroment().baseUrl}/pedido.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'actMonto_devhora',
      'bidpedido': idPedido,
      'bmonto': monto
    });
    return resp;
  }

}