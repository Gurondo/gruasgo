part of 'usuario_pedido_bloc.dart';

class UsuarioPedidoState extends Equatable{

  final Set<Marker> markers;
  final Set<Polyline> polylines;

  // detalle pedido
  final String distancia;
  final String duracion;

  // Cuando se busca un conductor
  final int contador;

  // Cuando el pedido es aceptado
  final String idConductor;

  // Estado del pedido
  

  // Notificacion del conductor
  final bool conductorEstaAqui;
  const UsuarioPedidoState({
    this.markers = const {},
    this.polylines = const {},
    this.contador = 0,
    this.idConductor = '',
    this.distancia = '',
    this.duracion = '',
    this.conductorEstaAqui = false
  });

  UsuarioPedidoState copyWitch({
    int? contador,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    String? idConductor,
    String? distancia,
    String? duracion,
    bool? conductorEstaAqui,
    LatLng? coordenadaConductor
  }) => UsuarioPedidoState(
    contador: contador ?? this.contador,
    markers: markers ?? this.markers,
    idConductor: idConductor ?? this.idConductor,
    distancia: distancia ?? this.distancia,
    duracion: duracion ?? this.duracion,
    polylines: polylines ?? this.polylines,
    conductorEstaAqui: conductorEstaAqui ?? this.conductorEstaAqui,
  );

  @override
  List<Object?> get props => [contador, markers, idConductor, distancia, duracion, polylines, conductorEstaAqui];
}
