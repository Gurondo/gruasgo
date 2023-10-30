part of 'usuario_pedido_bloc.dart';

class UsuarioPedidoState {

  final LatLng? origen;
  final LatLng? destino;  

  // Cuando se busca un conductor
  final int contador;


  UsuarioPedidoState({
    this.origen,
    this.destino,
    this.contador = 0
  });

  UsuarioPedidoState copyWitch({
    LatLng? origen,
    LatLng? destino,
    int? contador
  }) => UsuarioPedidoState(
    origen: origen ?? this.origen,
    destino: destino ?? this.destino,
    contador: contador ?? this.contador
  );
}
