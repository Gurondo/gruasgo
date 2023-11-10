// To parse this JSON data, do
//
//     final responseEstadoPedido = responseEstadoPedidoFromJson(jsonString);

import 'dart:convert';

List<ResponseEstadoPedido> responseEstadoPedidoFromJson(String str) => List<ResponseEstadoPedido>.from(json.decode(str).map((x) => ResponseEstadoPedido.fromJson(x)));

String responseEstadoPedidoToJson(List<ResponseEstadoPedido> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ResponseEstadoPedido {
    String the0;
    String the1;
    String the2;
    String the3;
    String the4;
    String the5;
    String the6;
    String the7;
    DateTime the8;
    String the9;
    String the10;
    String the11;
    String the12;
    String the13;
    String the14;
    String the15;
    String the16;
    String the17;
    String the18;
    String the19;
    String the20;
    String the21;
    String idConductor;
    String lat;
    String log;
    String estado;
    String idPedido;
    String idUsuario;
    String idVehiculo;
    DateTime fecha;
    String hora;
    String ubiInicial;
    String iniLat;
    String iniLog;
    String ubiFinal;
    String finalLat;
    String finalLog;
    String metodoPago;
    String monto;
    String servicio;
    String descripCarga;
    String celularEntrega;

    ResponseEstadoPedido({
        required this.the0,
        required this.the1,
        required this.the2,
        required this.the3,
        required this.the4,
        required this.the5,
        required this.the6,
        required this.the7,
        required this.the8,
        required this.the9,
        required this.the10,
        required this.the11,
        required this.the12,
        required this.the13,
        required this.the14,
        required this.the15,
        required this.the16,
        required this.the17,
        required this.the18,
        required this.the19,
        required this.the20,
        required this.the21,
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
    });

    factory ResponseEstadoPedido.fromJson(Map<String, dynamic> json) => ResponseEstadoPedido(
        the0: json["0"],
        the1: json["1"],
        the2: json["2"],
        the3: json["3"],
        the4: json["4"],
        the5: json["5"],
        the6: json["6"],
        the7: json["7"],
        the8: DateTime.parse(json["8"]),
        the9: json["9"],
        the10: json["10"],
        the11: json["11"],
        the12: json["12"],
        the13: json["13"],
        the14: json["14"],
        the15: json["15"],
        the16: json["16"],
        the17: json["17"],
        the18: json["18"],
        the19: json["19"],
        the20: json["20"],
        the21: json["21"],
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
    );

    Map<String, dynamic> toJson() => {
        "0": the0,
        "1": the1,
        "2": the2,
        "3": the3,
        "4": the4,
        "5": the5,
        "6": the6,
        "7": the7,
        "8": "${the8.year.toString().padLeft(4, '0')}-${the8.month.toString().padLeft(2, '0')}-${the8.day.toString().padLeft(2, '0')}",
        "9": the9,
        "10": the10,
        "11": the11,
        "12": the12,
        "13": the13,
        "14": the14,
        "15": the15,
        "16": the16,
        "17": the17,
        "18": the18,
        "19": the19,
        "20": the20,
        "21": the21,
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
    };
}
