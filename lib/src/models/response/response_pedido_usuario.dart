// To parse this JSON data, do
//
//     final responsePedidoUsuario = responsePedidoUsuarioFromJson(jsonString);

import 'dart:convert';

List<ResponsePedidoUsuario> responsePedidoUsuarioFromJson(String str) => List<ResponsePedidoUsuario>.from(json.decode(str).map((x) => ResponsePedidoUsuario.fromJson(x)));

String responsePedidoUsuarioToJson(List<ResponsePedidoUsuario> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ResponsePedidoUsuario {
    String the0;
    String the1;
    String the2;
    String the3;
    String the4;
    String the5;
    DateTime the6;
    String the7;
    String the8;
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
    String peIdPedido;
    String usIdUsuario;
    String usNombreUsuario;
    String vePlaca;
    String coIdConductor;
    String coNombreConductor;
    DateTime peFecha;
    String peHora;
    String peUbiInicial;
    String peIniLat;
    String peIniLog;
    String peUbiFinal;
    String peFinalLat;
    String peFinalLog;
    String peEstado;
    String peMetodoPago;
    String peMonto;
    String peServicio;
    String peDescripCarga;
    String peCelularEntrega;

    ResponsePedidoUsuario({
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
    });

    factory ResponsePedidoUsuario.fromJson(Map<String, dynamic> json) => ResponsePedidoUsuario(
        the0: json["0"],
        the1: json["1"],
        the2: json["2"],
        the3: json["3"],
        the4: json["4"],
        the5: json["5"],
        the6: DateTime.parse(json["6"]),
        the7: json["7"],
        the8: json["8"],
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
    );

    Map<String, dynamic> toJson() => {
        "0": the0,
        "1": the1,
        "2": the2,
        "3": the3,
        "4": the4,
        "5": the5,
        "6": "${the6.year.toString().padLeft(4, '0')}-${the6.month.toString().padLeft(2, '0')}-${the6.day.toString().padLeft(2, '0')}",
        "7": the7,
        "8": the8,
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
    };
}
