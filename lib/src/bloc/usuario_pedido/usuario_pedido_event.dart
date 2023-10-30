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

class OnSelected extends UsuarioPedidoEvent{
  final String name;
  final String type;
  OnSelected(this.name, this.type);
}

class OnActualizarContador extends UsuarioPedidoEvent{
  final int contador;
  OnActualizarContador(this.contador);
}

class OnSetContador extends UsuarioPedidoEvent{
  final int contador;
  OnSetContador(this.contador);
}