// To parse this JSON data, do
//
//     final responseEstado = responseEstadoFromJson(jsonString);

import 'dart:convert';

List<ResponseEstado> responseEstadoFromJson(String str) => List<ResponseEstado>.from(json.decode(str).map((x) => ResponseEstado.fromJson(x)));

String responseEstadoToJson(List<ResponseEstado> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ResponseEstado {
    int id;
    int idConductor;
    double lat;
    double log;
    String estado;
    int idPedido;

    ResponseEstado({
        required this.id,
        required this.idConductor,
        required this.lat,
        required this.log,
        required this.estado,
        required this.idPedido,
    });

    factory ResponseEstado.fromJson(Map<String, dynamic> json) => ResponseEstado(
        id: json["id"],
        idConductor: json["idConductor"],
        lat: json["Lat"],
        log: json["Log"],
        estado: json["Estado"],
        idPedido: json["IdPedido"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "idConductor": idConductor,
        "Lat": lat,
        "Log": log,
        "Estado": estado,
        "IdPedido": idPedido,
    };
}
