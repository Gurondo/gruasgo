import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/pages/login/login_usr_model.dart';
import 'package:gruasgo/src/services/http/calificacion_services.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {

  UserModel? user;

  // Controlador para la camara
  bool camaraEnfocada = true;

  UserBloc() : super(const UserState()) {
    on<UserEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<OnSetMarker>((event, emit){
      emit(state.copyWitch(markerSeleccionado: event.marker));
    });

    on<OnSetIsClicPin>((event, emit){
      emit(state.copyWitch(isClickPin: event.isClickPin));
    });


  }




  Future<bool> enviarCalificacion({
    required int idPedido,
    required String puntaje,
    required String tipoUsuario,
    required String observaciones
  }) async {

    final response = await CalificacionService.guardarCalificacion(
      idPedido: idPedido, 
      puntaje: puntaje, 
      tipoUsuario: tipoUsuario, 
      observaciones: observaciones
    );

    print(response.body);
    if (response.statusCode != 200) return false;

    return true;
  }
}
