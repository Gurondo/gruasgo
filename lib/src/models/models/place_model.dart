import 'package:gruasgo/src/models/models.dart';

class PlaceModel {
    String? name;
    PositionModel? position;

    PlaceModel({
        this.name,
        this.position,
    });

    factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
        name: json["name"],
        position: json["position"] == null ? null : PositionModel.fromJson(json["position"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "position": position?.toJson(),
    };
}