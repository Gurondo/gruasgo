// To parse this JSON data, do
//
//     final responseEstado = responseEstadoFromJson(jsonString);

import 'dart:convert';

List<ResponseEstado> responseEstadoFromJson(String str) => List<ResponseEstado>.from(json.decode(str).map((x) => ResponseEstado.fromJson(x)));

String responseEstadoToJson(List<ResponseEstado> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ResponseEstado {
    String the0;
    String the1;
    String the2;
    String the3;
    String the4;
    String the5;
    String id;
    String idConductor;
    String lat;
    String log;
    String estado;
    String idPedido;

    ResponseEstado({
        required this.the0,
        required this.the1,
        required this.the2,
        required this.the3,
        required this.the4,
        required this.the5,
        required this.id,
        required this.idConductor,
        required this.lat,
        required this.log,
        required this.estado,
        required this.idPedido,
    });

    factory ResponseEstado.fromJson(Map<String, dynamic> json) => ResponseEstado(
        the0: json["0"],
        the1: json["1"],
        the2: json["2"],
        the3: json["3"],
        the4: json["4"],
        the5: json["5"],
        id: json["id"],
        idConductor: json["idConductor"],
        lat: json["Lat"],
        log: json["Log"],
        estado: json["Estado"],
        idPedido: json["IdPedido"],
    );

    Map<String, dynamic> toJson() => {
        "0": the0,
        "1": the1,
        "2": the2,
        "3": the3,
        "4": the4,
        "5": the5,
        "id": id,
        "idConductor": idConductor,
        "Lat": lat,
        "Log": log,
        "Estado": estado,
        "IdPedido": idPedido,
    };
}
