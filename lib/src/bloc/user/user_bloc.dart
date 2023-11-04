import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/pages/login/login_usr_model.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {

  UserModel? user;

  UserBloc() : super(const UserState()) {
    on<UserEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<OnSetMarker>((event, emit){
      emit(state.copyWitch(markerSeleccionado: event.marker));
    });
  }
}
