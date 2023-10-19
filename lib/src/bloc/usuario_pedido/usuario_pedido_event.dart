part of 'usuario_pedido_bloc.dart';

@immutable
class UsuarioPedidoEvent {}

class OnSetOrigen extends UsuarioPedidoEvent{
  final LatLng origen;
  OnSetOrigen(this.origen);
}

class OnSetDestino extends UsuarioPedidoEvent{
  final LatLng destino;
  OnSetDestino(this.destino);
}