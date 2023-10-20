import 'package:bloc/bloc.dart';
import 'package:gruasgo/src/pages/login/login_usr_model.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {

  UserModel? user;

  UserBloc() : super(UserState()) {
    on<UserEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
