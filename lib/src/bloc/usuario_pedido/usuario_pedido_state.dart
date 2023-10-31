part of 'usuario_pedido_bloc.dart';

class UsuarioPedidoState extends Equatable{

  final LatLng? origen;
  final LatLng? destino;  


  final LatLng? conductor;

  // Cuando se busca un conductor
  final int contador;


  const UsuarioPedidoState({
    this.origen,
    this.destino,
    this.conductor,
    this.contador = 0
  });

  UsuarioPedidoState copyWitch({
    LatLng? origen,
    LatLng? destino,
    int? contador,
    LatLng? conductor,
  }) => UsuarioPedidoState(
    origen: origen ?? this.origen,
    destino: destino ?? this.destino,
    contador: contador ?? this.contador,
    conductor: conductor ?? this.conductor
  );

  @override
  List<Object?> get props => [origen, destino, conductor, contador];
}
