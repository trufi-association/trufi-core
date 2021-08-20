part of 'bus_cubit.dart';

class Bus {
  String name;
  int id;
  String from;
  String to;

//create a bus data

  Bus({this.id, this.name, this.from, this.to});

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
        name: json["name"] as String,
        from: json["from"] as String,
        id: json["id"] as int,
        to: json["to"] as String);
  }
}
