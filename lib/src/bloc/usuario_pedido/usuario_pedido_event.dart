part of 'usuario_pedido_bloc.dart';

@immutable
class UsuarioPedidoEvent {}

class OnActualizarContador extends UsuarioPedidoEvent{
  final int contador;
  OnActualizarContador(this.contador);
}

class OnSetContador extends UsuarioPedidoEvent{
  final int contador;
  OnSetContador(this.contador);
}

class OnSetAddNewMarkets extends UsuarioPedidoEvent{
  final Marker marker;
  OnSetAddNewMarkets(this.marker);
}

class OnSetAddNewPolylines extends UsuarioPedidoEvent{
  final Polyline polyline;
  OnSetAddNewPolylines(this.polyline);
}

class OnSetIdConductor extends UsuarioPedidoEvent{
  final int idConductor;
  OnSetIdConductor(this.idConductor);
}

class OnUpdateDistanciaDuracion extends UsuarioPedidoEvent{
  final String distancia;
  final String duracion;
  OnUpdateDistanciaDuracion({required this.distancia, required this.duracion});
}

class OnDeleteMarkerById extends UsuarioPedidoEvent{
  final MarkerIdEnum markerIdEnum;
  OnDeleteMarkerById(this.markerIdEnum);
}

class OnConductorEstaAqui extends UsuarioPedidoEvent{
  final bool conductorEstaAqui;
  OnConductorEstaAqui(this.conductorEstaAqui);
}

class OnRemoveMarker extends UsuarioPedidoEvent{
  final MarkerIdEnum id;
  OnRemoveMarker(this.id);
}

class OnClearPolylines extends UsuarioPedidoEvent{
  OnClearPolylines();
}

class OnSetEstadoPedidoAceptado extends UsuarioPedidoEvent{
  final EstadoPedidoAceptadoEnum estadoPedidoAceptado;
  OnSetEstadoPedidoAceptado(this.estadoPedidoAceptado);
}
