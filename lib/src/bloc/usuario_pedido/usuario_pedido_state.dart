part of 'usuario_pedido_bloc.dart';

class UsuarioPedidoState extends Equatable{

  final Set<Marker> markers;
  final Set<Polyline> polylines;

  // detalle pedido
  final String distancia;
  final String duracion;

  // Cuando el pedido es aceptado
  final int idConductor;

  // Estado del pedido
  final EstadoPedidoAceptadoEnum estadoPedidoAceptado;

  // Notificacion del conductor
  final bool conductorEstaAqui;
  const UsuarioPedidoState({
    this.markers = const {},
    this.polylines = const {},
    this.idConductor = -1,
    this.distancia = '',
    this.duracion = '',
    this.conductorEstaAqui = false,
    this.estadoPedidoAceptado = EstadoPedidoAceptadoEnum.sinPedido
  });

  UsuarioPedidoState copyWitch({
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    int? idConductor,
    String? distancia,
    String? duracion,
    bool? conductorEstaAqui,
    bool? botonCancelarPedido,
    EstadoPedidoAceptadoEnum? estadoPedidoAceptado
  }) => UsuarioPedidoState(
    markers: markers ?? this.markers,
    idConductor: idConductor ?? this.idConductor,
    distancia: distancia ?? this.distancia,
    duracion: duracion ?? this.duracion,
    polylines: polylines ?? this.polylines,
    conductorEstaAqui: conductorEstaAqui ?? this.conductorEstaAqui,
    estadoPedidoAceptado: estadoPedidoAceptado ?? this.estadoPedidoAceptado
  );

  @override
  List<Object?> get props => [markers, idConductor, distancia, duracion, polylines, conductorEstaAqui, estadoPedidoAceptado];
}
