part of 'bus_cubit.dart';

class Bus {
  Properties properites;
  Geometry geometry;
  List nodes;
  Map<String, dynamic> busdata;

//create a bus data

  Bus({this.properites, this.geometry, this.nodes});

  factory Bus.fromJson(Map<String, dynamic> json) => Bus(
      properites:
          Properties.fromjson(json["properties"] as Map<String, dynamic>),
      geometry: Geometry.forJson(json["geometry"] as Map<String, dynamic>),
      nodes: json["nodes"] as List);
}

class Geometry {
  String type = "LineString";
  List coords = [];
  Geometry({this.coords});
  factory Geometry.forJson(Map<String, dynamic> json) =>
      Geometry(coords: json["coordinates"] as List);
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
