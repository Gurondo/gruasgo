import 'package:gruasgo/src/global/enviroment.dart';
import 'package:http/http.dart' as http;

class ConductorService{

  Future obtenerPedido({required String idConductor}) async{
    var urlParce = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'BUCON',
      'bidconductor': idConductor
    });

    return resp;
  }

  Future actualizarEstadoPedido({
    required String idConductor,
    required String idPedido,
    required String estado
  }) async{
    var urlParce = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'UPESPE',
      'bidconductor': idConductor,
      'bidpedido': idPedido,
      'idPedido': estado
    });

    return resp;
  }

  Future actualizarUbicacion({
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

  Future eliminarConductor({
    required String idConductor
  }) async{
    var urlParce = Uri.parse('${Enviroment().baseUrl}/conductorDisponible.php');
    final resp = await http.post(urlParce, body: {
      'btip': 'DEL',
      'bidconductor': idConductor,
    });
    return resp;
  }

}