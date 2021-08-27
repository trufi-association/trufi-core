part of 'bus_cubit.dart';

class Bus {
  Properties properites;
  Geometry geometry;

//create a bus data

  Bus({
    this.properites,
    this.geometry,
  });

  factory Bus.fromJson(Map<String, dynamic> json) => Bus(
      properites:
          Properties.fromjson(json["properties"] as Map<String, dynamic>),
      geometry: Geometry.forJson(json["geometry"] as Map<String, dynamic>));
}

class Geometry {
  String type = "LineString";
  List coords = [];
  List nodes = [];
  Geometry({this.coords, this.nodes});
  factory Geometry.forJson(Map<String, dynamic> json) => Geometry(
      coords: json["coordinates"] as List, nodes: json["nodes"] as List);
}

class Properties {
  String name;
  String modeOfTransport;
  int id;
  String stroke;
  int strokeWidth;

  Properties(
      {this.id,
      this.name,
      this.modeOfTransport,
      this.stroke,
      this.strokeWidth});

  factory Properties.fromjson(Map<String, dynamic> json) => Properties(
        id: json["id"] as int,
        name: json["name"] as String,
        modeOfTransport: json["route"] as String,
        stroke: json["stroke"] as String,
        strokeWidth: json["stroke-width"] as int,
      );
}
