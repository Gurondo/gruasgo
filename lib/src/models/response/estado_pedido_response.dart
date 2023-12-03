// To parse this JSON data, do
//
//     final responseEstadoPedido = responseEstadoPedidoFromJson(jsonString);

import 'dart:convert';

List<ResponseEstadoPedido> responseEstadoPedidoFromJson(String str) => List<ResponseEstadoPedido>.from(json.decode(str).map((x) => ResponseEstadoPedido.fromJson(x)));

String responseEstadoPedidoToJson(List<ResponseEstadoPedido> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ResponseEstadoPedido {
    String the16;
    String idConductor;
    double lat;
    double log;
    String estado;
    int idPedido;
    String idUsuario;
    String idVehiculo;
    DateTime fecha;
    String hora;
    String ubiInicial;
    double iniLat;
    double iniLog;
    String ubiFinal;
    double finalLat;
    double finalLog;
    String metodoPago;
    int monto;
    String servicio;
    String descripCarga;
    int celularEntrega;
    String? horaIni;
    String? horaFin;

    ResponseEstadoPedido({
        required this.the16,
        required this.idConductor,
        required this.lat,
        required this.log,
        required this.estado,
        required this.idPedido,
        required this.idUsuario,
        required this.idVehiculo,
        required this.fecha,
        required this.hora,
        required this.ubiInicial,
        required this.iniLat,
        required this.iniLog,
        required this.ubiFinal,
        required this.finalLat,
        required this.finalLog,
        required this.metodoPago,
        required this.monto,
        required this.servicio,
        required this.descripCarga,
        required this.celularEntrega,
        required this.horaIni,
        required this.horaFin,
    });

    factory ResponseEstadoPedido.fromJson(Map<String, dynamic> json) => ResponseEstadoPedido(
        the16: json["16"],
        idConductor: json["idConductor"],
        lat: json["Lat"],
        log: json["Log"],
        estado: json["Estado"],
        idPedido: json["idPedido"],
        idUsuario: json["idUsuario"],
        idVehiculo: json["idVehiculo"],
        fecha: DateTime.parse(json["Fecha"]),
        hora: json["Hora"],
        ubiInicial: json["Ubi_Inicial"],
        iniLat: json["ini_lat"],
        iniLog: json["ini_log"],
        ubiFinal: json["Ubi_Final"],
        finalLat: json["final_lat"],
        finalLog: json["final_log"],
        metodoPago: json["MetodoPago"],
        monto: json["Monto"],
        servicio: json["Servicio"],
        descripCarga: json["DescripCarga"],
        celularEntrega: json["CelularEntrega"],
        horaIni: json["HoraIni"],
        horaFin: json["HoraFin"],
    );

    Map<String, dynamic> toJson() => {
        "16": the16,
        "idConductor": idConductor,
        "Lat": lat,
        "Log": log,
        "Estado": estado,
        "idPedido": idPedido,
        "idUsuario": idUsuario,
        "idVehiculo": idVehiculo,
        "Fecha": "${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}",
        "Hora": hora,
        "Ubi_Inicial": ubiInicial,
        "ini_lat": iniLat,
        "ini_log": iniLog,
        "Ubi_Final": ubiFinal,
        "final_lat": finalLat,
        "final_log": finalLog,
        "MetodoPago": metodoPago,
        "Monto": monto,
        "Servicio": servicio,
        "DescripCarga": descripCarga,
        "CelularEntrega": celularEntrega,
        "HoraIni": horaIni,
        "HoraFin": horaFin,
    };
}
