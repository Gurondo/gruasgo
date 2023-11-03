part of 'conductor_bloc.dart';

class ConductorState extends Equatable {

  final double tiempo;

  final DetalleNotificacionConductor? detallePedido;
  final Set<Marker> markers;
  final Set<Polyline> polylines;


  const ConductorState({
    this.tiempo = 0,
    this.detallePedido,
    this.markers = const {},
    this.polylines = const {}
  });

  ConductorState copyWitch({
    double? tiempo,
    DetalleNotificacionConductor? detallePedido,
    Set<Marker>? markers,
    Set<Polyline>? polylines
  }) => ConductorState(
    tiempo: tiempo ?? this.tiempo,
    detallePedido: detallePedido ?? this.detallePedido,
    markers: markers ?? this.markers,
    polylines: polylines ?? this.polylines
  );

  @override
  List<Object?> get props => [tiempo, detallePedido, markers, polylines];
}
