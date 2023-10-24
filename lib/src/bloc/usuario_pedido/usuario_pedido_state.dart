part of 'usuario_pedido_bloc.dart';

class UsuarioPedidoState {

  final LatLng? origen;
  final LatLng? destino;  


  UsuarioPedidoState({
    this.origen,
    this.destino,
  });

  UsuarioPedidoState copyWitch({
    LatLng? origen,
    LatLng? destino,
  }) => UsuarioPedidoState(
    origen: origen ?? this.origen,
    destino: destino ?? this.destino,
  );
}
