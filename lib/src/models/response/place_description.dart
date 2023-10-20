// To parse this JSON data, do
//
//     final placesDescriptionResponse = placesDescriptionResponseFromJson(jsonString);

import 'dart:convert';

import 'package:gruasgo/src/models/models.dart';

PlacesDescriptionResponse placesDescriptionResponseFromJson(String str) => PlacesDescriptionResponse.fromJson(json.decode(str));

String placesDescriptionResponseToJson(PlacesDescriptionResponse data) => json.encode(data.toJson());

class PlacesDescriptionResponse {
    bool ok;
    List<PlaceDescriptionModel> place;

    PlacesDescriptionResponse({
        required this.ok,
        required this.place,
    });

    factory PlacesDescriptionResponse.fromJson(Map<String, dynamic> json) => PlacesDescriptionResponse(
        ok: json["ok"],
        place: List<PlaceDescriptionModel>.from(json["place"].map((x) => PlaceDescriptionModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "place": List<dynamic>.from(place.map((x) => x.toJson())),
    };
}


