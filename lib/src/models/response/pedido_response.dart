// To parse this JSON data, do
//
//     final responsePedido = responsePedidoFromJson(jsonString);

import 'dart:convert';

List<ResponsePedido> responsePedidoFromJson(String str) => List<ResponsePedido>.from(json.decode(str).map((x) => ResponsePedido.fromJson(x)));

String responsePedidoToJson(List<ResponsePedido> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ResponsePedido {
    int idPedido;
    // TODO Ver esto, dice que es int, despues String, es raro
    String idUsuario;
    String idVehiculo;
    String idConductor;
    DateTime fecha;
    String hora;
    String ubiInicial;
    double iniLat;
    double iniLog;
    String ubiFinal;
    double finalLat;
    double finalLog;
    String estado;
    String metodoPago;
    int monto;
    String servicio;
    String descripCarga;
    int celularEntrega;

    ResponsePedido({
        required this.idPedido,
        required this.idUsuario,
        required this.idVehiculo,
        required this.idConductor,
        required this.fecha,
        required this.hora,
        required this.ubiInicial,
        required this.iniLat,
        required this.iniLog,
        required this.ubiFinal,
        required this.finalLat,
        required this.finalLog,
        required this.estado,
        required this.metodoPago,
        required this.monto,
        required this.servicio,
        required this.descripCarga,
        required this.celularEntrega,
    });

    factory ResponsePedido.fromJson(Map<String, dynamic> json) => ResponsePedido(
        idPedido: json["idPedido"],
        idUsuario: json["idUsuario"],
        idVehiculo: json["idVehiculo"],
        idConductor: json["idConductor"],
        fecha: DateTime.parse(json["Fecha"]),
        hora: json["Hora"],
        ubiInicial: json["Ubi_Inicial"],
        iniLat: json["ini_lat"],
        iniLog: json["ini_log"],
        ubiFinal: json["Ubi_Final"],
        finalLat: json["final_lat"],
        finalLog: json["final_log"],
        estado: json["Estado"],
        metodoPago: json["MetodoPago"],
        monto: json["Monto"],
        servicio: json["Servicio"],
        descripCarga: json["DescripCarga"],
        celularEntrega: json["CelularEntrega"],
    );

    Map<String, dynamic> toJson() => {
        "idPedido": idPedido,
        "idUsuario": idUsuario,
        "idVehiculo": idVehiculo,
        "idConductor": idConductor,
        "Fecha": "${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}",
        "Hora": hora,
        "Ubi_Inicial": ubiInicial,
        "ini_lat": iniLat,
        "ini_log": iniLog,
        "Ubi_Final": ubiFinal,
        "final_lat": finalLat,
        "final_log": finalLog,
        "Estado": estado,
        "MetodoPago": metodoPago,
        "Monto": monto,
        "Servicio": servicio,
        "DescripCarga": descripCarga,
        "CelularEntrega": celularEntrega,
    };
}
