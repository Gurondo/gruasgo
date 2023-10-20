class PlaceDescriptionModel {
    String longName;
    String shortName;
    List<String> types;

    PlaceDescriptionModel({
        required this.longName,
        required this.shortName,
        required this.types,
    });

    factory PlaceDescriptionModel.fromJson(Map<String, dynamic> json) => PlaceDescriptionModel(
        longName: json["long_name"],
        shortName: json["short_name"],
        types: List<String>.from(json["types"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "long_name": longName,
        "short_name": shortName,
        "types": List<dynamic>.from(types.map((x) => x)),
    };
}