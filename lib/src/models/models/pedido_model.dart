import 'dart:ffi';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class PedidoModel{
  
  String btip;
  String bidpedido;
  String bidusuario;
  String bubinicial;
  String bubfinal;
  String bmetodopago;
  double bmonto;
  String bservicio;
  String bdescarga;
  int bcelentrega;
  LatLng origen;
  LatLng destino;

  PedidoModel({
    required this.btip,
    required this.bidpedido,
    required this.bidusuario,
    required this.bubinicial,
    required this.bubfinal,
    required this.bmetodopago,
    required this.bmonto,
    required this.bservicio,
    required this.bdescarga,
    required this.bcelentrega,
    required this.origen,
    required this.destino
  });

}