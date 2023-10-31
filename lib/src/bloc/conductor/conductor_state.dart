part of 'conductor_bloc.dart';

class ConductorState extends Equatable {

  final double tiempo;

  const ConductorState({
    this.tiempo = 0
  });

  ConductorState copyWitch({
    double? tiempo
  }) => ConductorState(
    tiempo: tiempo ?? this.tiempo
  );

  @override
  List<Object> get props => [tiempo];
}
