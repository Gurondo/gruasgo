part of 'user_bloc.dart';

class UserState extends Equatable{

  final Marker? markerSeleccionado;
  final bool isClickPin;

  const UserState({
    this.markerSeleccionado,
    this.isClickPin = false
  });

  UserState copyWitch({
    Marker? markerSeleccionado,
    bool? isClickPin
  }) => UserState(
    markerSeleccionado: markerSeleccionado ?? this.markerSeleccionado,
    isClickPin: isClickPin ?? this.isClickPin
  );

  @override
  List<Object?> get props => [markerSeleccionado, isClickPin];

}

