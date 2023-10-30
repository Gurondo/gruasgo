part of 'conductor_bloc.dart';

class ConductorState {

  final double tiempo;

  ConductorState({
    this.tiempo = 0
  });

  ConductorState copyWitch({
    double? tiempo
  }) => ConductorState(
    tiempo: tiempo ?? this.tiempo
  );

}
