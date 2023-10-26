import 'package:bloc/bloc.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
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

  void openSocket({required lat, required lng}) {
    SocketService.open();

    SocketService.emit('conductor online', {
      'id': userBloc.user?.idUsuario,
      'lat': lat,
      'lng': lng,
      'servicio': 'gruas'
    });

    respuestaSolicitudConductor();
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
      print(data);
    });

  }
  
}
