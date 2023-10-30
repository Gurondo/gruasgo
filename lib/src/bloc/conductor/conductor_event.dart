part of 'conductor_bloc.dart';

class ConductorEvent {}

class OnSetTiempo extends ConductorEvent{
  double tiempo;
  OnSetTiempo(this.tiempo);
}