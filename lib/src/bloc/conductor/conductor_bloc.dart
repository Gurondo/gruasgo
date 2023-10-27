import 'package:bloc/bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/models/response/google_map_direction.dart';
import 'package:gruasgo/src/services/http/google_map_services.dart';
import 'package:gruasgo/src/services/socket_services.dart';
import 'package:meta/meta.dart';

part 'conductor_event.dart';
part 'conductor_state.dart';

class ConductorBloc extends Bloc<ConductorEvent, ConductorState> {

  UserBloc userBloc;

  ConductorBloc({
    required this.userBloc
  }) : super(ConductorState()) {
    on<ConductorEvent>((event, emit) {
      // TODO: implement event handler
    });
  }

  Future<List<PointLatLng>?> getPolylines({
    required LatLng origen,
    required LatLng destino,
  }) async{
    
    // const key = 'AIzaSyAM_GlhLkiLrtgBL5G_Pteq1o1I-6C9ljA';
    // var urlParce = Uri.parse('https://maps.googleapis.com/maps/api/directions/json?destination=${origen.latitude},${origen.longitude}&origin=${destino.latitude},${destino.longitude}&key=$key');
    // final resp = await http.get(urlParce);

    final resp = await GoogleMapServices.googleDirections( origen: origen, destino: destino);
    
    if (resp.statusCode == 200){
      final googleMapDirection = googleMapDirectionFromJson(resp.body);
      return PolylinePoints().decodePolyline(googleMapDirection.routes[0].overviewPolyline.points);
    }
    return null;

  }

  void openSocket({required lat, required lng}) {
    SocketService.open();

    SocketService.emit('conductor online', {
      'id': userBloc.user?.idUsuario,
      'lat': lat,
      'lng': lng,
      'servicio': 'gruas'
    });

  }

  void closeSocket() {
    SocketService.close();
  }

  void updatePosition({required lat, required lng}){

    SocketService.emit('actualizar', {
      'lat': lat,
      'lng': lng
    });

  }

  void respuestaSolicitudConductor(){

    SocketService.on('solicitud pedido conductor', (data){
      print('respuesta aqui');
    });

  }

  void clearSocket(){
    SocketService.off('solicitud pedido conductor');
  }
  
}
