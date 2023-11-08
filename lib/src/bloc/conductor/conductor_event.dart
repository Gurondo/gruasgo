part of 'conductor_bloc.dart';

class ConductorEvent {}

class OnSetTiempo extends ConductorEvent{
  double tiempo;
  OnSetTiempo(this.tiempo);
}


class OnSetDetallePedido extends ConductorEvent{
  DetalleNotificacionConductor? detallePedido;
  OnSetDetallePedido(this.detallePedido);
}

class OnSetNewMarkets extends ConductorEvent{
  final Set<Marker> markets;
  OnSetNewMarkets(this.markets);
}

class OnSetAddPolyline extends ConductorEvent{
  final Polyline polyline;
  OnSetAddPolyline(this.polyline);
}

class OnSetClearPolylines extends ConductorEvent{
  OnSetClearPolylines();
}

class OnSetLimpiarPedidos extends ConductorEvent{
  OnSetLimpiarPedidos();
}

class OnSetAddMarker extends ConductorEvent{
  final Marker marker;
  OnSetAddMarker(this.marker);
}