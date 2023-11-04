part of 'user_bloc.dart';

class UserState extends Equatable{

  final Marker? markerSeleccionado;

  const UserState({
    this.markerSeleccionado
  });

  UserState copyWitch({
    Marker? markerSeleccionado
  }) => UserState(
    markerSeleccionado: markerSeleccionado ?? this.markerSeleccionado
  );

  @override
  List<Object?> get props => [markerSeleccionado];

}

