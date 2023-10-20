// To parse this JSON data, do
//
//     final placesResponse = placesResponseFromJson(jsonString);

import 'dart:convert';

import 'package:gruasgo/src/models/models/place_model.dart';

PlacesResponse placesResponseFromJson(String str) => PlacesResponse.fromJson(json.decode(str));

String placesResponseToJson(PlacesResponse data) => json.encode(data.toJson());

class PlacesResponse {
    bool ok;
    List<PlaceModel> places;

    PlacesResponse({
        required this.ok,
        required this.places,
    });

    factory PlacesResponse.fromJson(Map<String, dynamic> json) => PlacesResponse(
        ok: json["ok"],
        places: List<PlaceModel>.from(json["places"].map((x) => PlaceModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "places": List<dynamic>.from(places.map((x) => x.toJson())),
    };
}




