class PositionModel {
    double lat;
    double lng;

    PositionModel({
        required this.lat,
        required this.lng,
    });

    factory PositionModel.fromJson(Map<String, dynamic> json) => PositionModel(
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
    };
}
