import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetalleNotificacionConductor {

    //     origen: [-17.8370698, -63.23666479999999], 
    //     destino: [-17.83886896671317, -63.23904678225518], 
    //     servicio: gruas, 
    //     cliente: Jose Ferdando, 
    //     cliente_id: 5, 
    //     nombre_origen: Doble vía la guardias, 
    //     nombre_destino: Distrito 10 Santa Cruz de la Sierra Andrés Ibáñez Province Santa Cruz Department Bolivia, 
    //     descarga: fdsfdsfdsfds, 
    //     referencia: 32165498, 
    //     monto: 50, 
    //     socketClientId: gSb207yjYJ__v9lbAAAD

  final LatLng origen;
  final LatLng destino;
  final String servicio;
  final String cliente;
  final String clienteId;
  final String nombreOrigen;
  final String nombreDestino;
  final String descripcionDescarga;
  final int referencia;
  final double monto;
  final String? socketClientId;
  final String pedidoId;
  final String estado;
  final String? horaInicio;
  final String? horaFin;
  final String? tiempoTranscurrido;

  DetalleNotificacionConductor({
    required this.origen,
    required this.destino,
    required this.servicio,
    required this.cliente,
    required this.clienteId,
    required this.nombreOrigen,
    required this.nombreDestino,
    required this.descripcionDescarga,
    required this.referencia,
    required this.monto,
    required this.socketClientId,
    required this.pedidoId,
    required this.estado,
    this.horaInicio,
    this.horaFin,
    this.tiempoTranscurrido
  });
}