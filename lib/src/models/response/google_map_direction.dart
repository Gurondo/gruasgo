// To parse this JSON data, do
//
//     final googleMapDirection = googleMapDirectionFromJson(jsonString);

import 'dart:convert';

GoogleMapDirection googleMapDirectionFromJson(String str) => GoogleMapDirection.fromJson(json.decode(str));

String googleMapDirectionToJson(GoogleMapDirection data) => json.encode(data.toJson());

class GoogleMapDirection {
    List<Route> routes;

    GoogleMapDirection({
        required this.routes,
    });

    factory GoogleMapDirection.fromJson(Map<String, dynamic> json) => GoogleMapDirection(
        routes: List<Route>.from(json["routes"].map((x) => Route.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "routes": List<dynamic>.from(routes.map((x) => x.toJson())),
    };
}

class GeocodedWaypoint {
    String geocoderStatus;
    String placeId;
    List<String> types;

    GeocodedWaypoint({
        required this.geocoderStatus,
        required this.placeId,
        required this.types,
    });

    factory GeocodedWaypoint.fromJson(Map<String, dynamic> json) => GeocodedWaypoint(
        geocoderStatus: json["geocoder_status"],
        placeId: json["place_id"],
        types: List<String>.from(json["types"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "geocoder_status": geocoderStatus,
        "place_id": placeId,
        "types": List<dynamic>.from(types.map((x) => x)),
    };
}

class Route {
    Bounds bounds;
    String copyrights;
    List<Leg> legs;
    Polyline overviewPolyline;
    String summary;
    List<dynamic> warnings;
    List<dynamic> waypointOrder;

    Route({
        required this.bounds,
        required this.copyrights,
        required this.legs,
        required this.overviewPolyline,
        required this.summary,
        required this.warnings,
        required this.waypointOrder,
    });

    factory Route.fromJson(Map<String, dynamic> json) => Route(
        bounds: Bounds.fromJson(json["bounds"]),
        copyrights: json["copyrights"],
        legs: List<Leg>.from(json["legs"].map((x) => Leg.fromJson(x))),
        overviewPolyline: Polyline.fromJson(json["overview_polyline"]),
        summary: json["summary"],
        warnings: List<dynamic>.from(json["warnings"].map((x) => x)),
        waypointOrder: List<dynamic>.from(json["waypoint_order"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "bounds": bounds.toJson(),
        "copyrights": copyrights,
        "legs": List<dynamic>.from(legs.map((x) => x.toJson())),
        "overview_polyline": overviewPolyline.toJson(),
        "summary": summary,
        "warnings": List<dynamic>.from(warnings.map((x) => x)),
        "waypoint_order": List<dynamic>.from(waypointOrder.map((x) => x)),
    };
}

class Bounds {
    Northeast northeast;
    Northeast southwest;

    Bounds({
        required this.northeast,
        required this.southwest,
    });

    factory Bounds.fromJson(Map<String, dynamic> json) => Bounds(
        northeast: Northeast.fromJson(json["northeast"]),
        southwest: Northeast.fromJson(json["southwest"]),
    );

    Map<String, dynamic> toJson() => {
        "northeast": northeast.toJson(),
        "southwest": southwest.toJson(),
    };
}

class Northeast {
    double lat;
    double lng;

    Northeast({
        required this.lat,
        required this.lng,
    });

    factory Northeast.fromJson(Map<String, dynamic> json) => Northeast(
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
    };
}

class Leg {
    Distance distance;
    Distance duration;
    String endAddress;
    Northeast endLocation;
    String startAddress;
    Northeast startLocation;
    List<Step> steps;
    List<dynamic> trafficSpeedEntry;
    List<dynamic> viaWaypoint;

    Leg({
        required this.distance,
        required this.duration,
        required this.endAddress,
        required this.endLocation,
        required this.startAddress,
        required this.startLocation,
        required this.steps,
        required this.trafficSpeedEntry,
        required this.viaWaypoint,
    });

    factory Leg.fromJson(Map<String, dynamic> json) => Leg(
        distance: Distance.fromJson(json["distance"]),
        duration: Distance.fromJson(json["duration"]),
        endAddress: json["end_address"],
        endLocation: Northeast.fromJson(json["end_location"]),
        startAddress: json["start_address"],
        startLocation: Northeast.fromJson(json["start_location"]),
        steps: List<Step>.from(json["steps"].map((x) => Step.fromJson(x))),
        trafficSpeedEntry: List<dynamic>.from(json["traffic_speed_entry"].map((x) => x)),
        viaWaypoint: List<dynamic>.from(json["via_waypoint"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "distance": distance.toJson(),
        "duration": duration.toJson(),
        "end_address": endAddress,
        "end_location": endLocation.toJson(),
        "start_address": startAddress,
        "start_location": startLocation.toJson(),
        "steps": List<dynamic>.from(steps.map((x) => x.toJson())),
        "traffic_speed_entry": List<dynamic>.from(trafficSpeedEntry.map((x) => x)),
        "via_waypoint": List<dynamic>.from(viaWaypoint.map((x) => x)),
    };
}

class Distance {
    String text;
    int value;

    Distance({
        required this.text,
        required this.value,
    });

    factory Distance.fromJson(Map<String, dynamic> json) => Distance(
        text: json["text"],
        value: json["value"],
    );

    Map<String, dynamic> toJson() => {
        "text": text,
        "value": value,
    };
}

class Step {
    Distance distance;
    Distance duration;
    Northeast endLocation;
    String htmlInstructions;
    Polyline polyline;
    Northeast startLocation;
    TravelMode travelMode;
    String? maneuver;

    Step({
        required this.distance,
        required this.duration,
        required this.endLocation,
        required this.htmlInstructions,
        required this.polyline,
        required this.startLocation,
        required this.travelMode,
        this.maneuver,
    });

    factory Step.fromJson(Map<String, dynamic> json) => Step(
        distance: Distance.fromJson(json["distance"]),
        duration: Distance.fromJson(json["duration"]),
        endLocation: Northeast.fromJson(json["end_location"]),
        htmlInstructions: json["html_instructions"],
        polyline: Polyline.fromJson(json["polyline"]),
        startLocation: Northeast.fromJson(json["start_location"]),
        travelMode: travelModeValues.map[json["travel_mode"]]!,
        maneuver: json["maneuver"],
    );

    Map<String, dynamic> toJson() => {
        "distance": distance.toJson(),
        "duration": duration.toJson(),
        "end_location": endLocation.toJson(),
        "html_instructions": htmlInstructions,
        "polyline": polyline.toJson(),
        "start_location": startLocation.toJson(),
        "travel_mode": travelModeValues.reverse[travelMode],
        "maneuver": maneuver,
    };
}

class Polyline {
    String points;

    Polyline({
        required this.points,
    });

    factory Polyline.fromJson(Map<String, dynamic> json) => Polyline(
        points: json["points"],
    );

    Map<String, dynamic> toJson() => {
        "points": points,
    };
}

enum TravelMode {
    DRIVING
}

final travelModeValues = EnumValues({
    "DRIVING": TravelMode.DRIVING
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap = map.map((k, v) => MapEntry(v, k));
        return reverseMap;
    }
}