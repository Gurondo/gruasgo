// To parse this JSON data, do
//
//     final responsePedidoUsuario = responsePedidoUsuarioFromJson(jsonString);

import 'dart:convert';

List<ResponsePedidoUsuario> responsePedidoUsuarioFromJson(String str) => List<ResponsePedidoUsuario>.from(json.decode(str).map((x) => ResponsePedidoUsuario.fromJson(x)));

String responsePedidoUsuarioToJson(List<ResponsePedidoUsuario> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ResponsePedidoUsuario {
    int peIdPedido;
    String usIdUsuario;
    String usNombreUsuario;
    String vePlaca;
    int coIdConductor;
    String coNombreConductor;
    DateTime peFecha;
    String peHora;
    String peUbiInicial;
    double peIniLat;
    double peIniLog;
    String peUbiFinal;
    double peFinalLat;
    double peFinalLog;
    String peEstado;
    String peMetodoPago;
    int peMonto;
    String peServicio;
    String peDescripCarga;
    int peCelularEntrega;
    double cdLatitud;
    double cdLongitud;

    ResponsePedidoUsuario({
        required this.peIdPedido,
        required this.usIdUsuario,
        required this.usNombreUsuario,
        required this.vePlaca,
        required this.coIdConductor,
        required this.coNombreConductor,
        required this.peFecha,
        required this.peHora,
        required this.peUbiInicial,
        required this.peIniLat,
        required this.peIniLog,
        required this.peUbiFinal,
        required this.peFinalLat,
        required this.peFinalLog,
        required this.peEstado,
        required this.peMetodoPago,
        required this.peMonto,
        required this.peServicio,
        required this.peDescripCarga,
        required this.peCelularEntrega,
        required this.cdLatitud,
        required this.cdLongitud
    });

    factory ResponsePedidoUsuario.fromJson(Map<String, dynamic> json) => ResponsePedidoUsuario(
        peIdPedido: json["pe_idPedido"],
        usIdUsuario: json["us_idUsuario"],
        usNombreUsuario: json["us_NombreUsuario"],
        vePlaca: json["ve_Placa"],
        coIdConductor: json["co_idConductor"],
        coNombreConductor: json["co_NombreConductor"],
        peFecha: DateTime.parse(json["pe_Fecha"]),
        peHora: json["pe_Hora"],
        peUbiInicial: json["pe_Ubi_Inicial"],
        peIniLat: json["pe_ini_lat"],
        peIniLog: json["pe_ini_log"],
        peUbiFinal: json["pe_Ubi_Final"],
        peFinalLat: json["pe_final_lat"],
        peFinalLog: json["pe_final_log"],
        peEstado: json["pe_Estado"],
        peMetodoPago: json["pe_MetodoPago"],
        peMonto: json["pe_Monto"],
        peServicio: json["pe_Servicio"],
        peDescripCarga: json["pe_DescripCarga"],
        peCelularEntrega: json["pe_CelularEntrega"],
        cdLatitud: json["cd_latitud"],
        cdLongitud: json["cd_longitud"]
    );

    Map<String, dynamic> toJson() => {
        "pe_idPedido": peIdPedido,
        "us_idUsuario": usIdUsuario,
        "us_NombreUsuario": usNombreUsuario,
        "ve_Placa": vePlaca,
        "co_idConductor": coIdConductor,
        "co_NombreConductor": coNombreConductor,
        "pe_Fecha": "${peFecha.year.toString().padLeft(4, '0')}-${peFecha.month.toString().padLeft(2, '0')}-${peFecha.day.toString().padLeft(2, '0')}",
        "pe_Hora": peHora,
        "pe_Ubi_Inicial": peUbiInicial,
        "pe_ini_lat": peIniLat,
        "pe_ini_log": peIniLog,
        "pe_Ubi_Final": peUbiFinal,
        "pe_final_lat": peFinalLat,
        "pe_final_log": peFinalLog,
        "pe_Estado": peEstado,
        "pe_MetodoPago": peMetodoPago,
        "pe_Monto": peMonto,
        "pe_Servicio": peServicio,
        "pe_DescripCarga": peDescripCarga,
        "pe_CelularEntrega": peCelularEntrega,
        "cd_latitud": cdLatitud,
        "cd_longitud": cdLongitud
    };
}
