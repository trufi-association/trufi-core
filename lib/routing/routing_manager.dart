import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class RoutingManager {
  static const String pathPoints = "assets/data/base/puntos.json";
  static const String pathLines = "assets/data/base/lineas.json";
  static const String pathRoutes = "assets/data/base/recorridos.json";
  static const String pathConnections = "assets/data/base/conexiones.json";
  static const String pathTransfers = "assets/data/base/transbordos.json";

  final points = Map<int, Point>();

  /// Load from json files
  void load(BuildContext context) async {
    final assetBundle = DefaultAssetBundle.of(context);
    final lines = Map<int, Line>();
    final routes = Map<int, Route>();
    final connections = Map<int, Connection>();
    json.decode(await assetBundle.loadString(pathPoints)).forEach(
      (json) {
        points[json['IDPUNTO']] = Point.fromJson(json);
      },
    );
    json.decode(await assetBundle.loadString(pathLines)).forEach(
      (json) {
        lines[json['IDLINEA']] = Line.fromJson(json);
      },
    );
    json.decode(await assetBundle.loadString(pathRoutes)).forEach(
      (json) {
        routes[json['IDRECORRIDO']] = Route.fromJson(
          json,
          lines[json['IDLINEA']],
        );
      },
    );
    json.decode(await assetBundle.loadString(pathConnections)).forEach(
      (json) {
        connections[json['IDCONEXION']] = Connection.fromJson(
          json,
          routes[json['IDRECORRIDO']],
          points[json['IDPUNTO']],
        );
      },
    );
    json.decode(await assetBundle.loadString(pathTransfers)).forEach(
      (json) {
        routes[json['IDRECORRIDO']].addTransfer(
          Transfer(connections[json['MINE']], connections[json['OTHER']]),
        );
      },
    );
  }

  /// load from json files
  void loadForTest() {
    final lines = Map<int, Line>();
    final routes = Map<int, Route>();
    final connections = Map<int, Connection>();
    json.decode(File(pathPoints).readAsStringSync()).forEach(
      (json) {
        points[json['IDPUNTO']] = Point.fromJson(json);
      },
    );
    json.decode(File(pathLines).readAsStringSync()).forEach(
      (json) {
        lines[json['IDLINEA']] = Line.fromJson(json);
      },
    );
    json.decode(File(pathRoutes).readAsStringSync()).forEach(
      (json) {
        routes[json['IDRECORRIDO']] =
            Route.fromJson(json, lines[json['IDLINEA']]);
      },
    );
    json.decode(File(pathConnections).readAsStringSync()).forEach(
      (json) {
        connections[json['IDCONEXION']] = Connection.fromJson(
          json,
          routes[json['IDRECORRIDO']],
          points[json['IDPUNTO']],
        );
      },
    );
    json.decode(File(pathTransfers).readAsStringSync()).forEach(
      (json) {
        routes[json['IDRECORRIDO']].addTransfer(
          Transfer(connections[json['MINE']], connections[json['OTHER']]),
        );
      },
    );
  }

  /// The [params] are latitude and longitude from origin and destination.
  ///
  /// Returns `RoutingResult` with simple and complex routes.
  RoutingResult findRoutes(
    double oLat,
    double oLng,
    double dLat,
    double dLng,
    int maxRoutes,
  ) {
    final origin = Point(oLat, oLng);
    final destination = Point(dLat, dLng);

    final origins = findConnections(origin);
    final destinations = findConnections(destination);

    final simpleRoutes = List<SimpleRoute>();
    final complexRoutes = List<ComplexRoute>();

    /// find common routes
    origins.forEach((originConnection) {
      destinations.forEach((destinationConnection) {
        if (originConnection.hasSameRoute(destinationConnection)) {
          if (originConnection.isValidRoute(destinationConnection)) {
            /// if the origin and destination has the same route and it is valid
            simpleRoutes.add(
              SimpleRoute(
                originConnection,
                destinationConnection,
              ),
            );
          }
        } else {
          originConnection.route.transfers.forEach((transfer) {
            if (transfer.isInMyWay(originConnection, destinationConnection)) {
              complexRoutes.add(
                ComplexRoute(
                  originConnection,
                  destinationConnection,
                  transfer,
                ),
              );
            }
          });
        }
      });
    });

    /// Sort simple results by distances
    simpleRoutes.sort((a, b) => a.distance.compareTo(b.distance));

    /// This part is for reduce results
    if (simpleRoutes.length > maxRoutes) {
      simpleRoutes.removeRange(maxRoutes, simpleRoutes.length);
      complexRoutes.clear();
    } else if (complexRoutes.length > maxRoutes) {
      /// Sort complex  results by total distances
      complexRoutes.sort((a, b) => a.distance.compareTo(b.distance));
      complexRoutes.removeRange(maxRoutes, complexRoutes.length);
    }

    /// Format complex result grouped by line
    final complexRouteGroup = Map<Line, ComplexRouteGroup>();
    complexRoutes.forEach((complexRoute) {
      final tmpGroup = complexRouteGroup[complexRoute.from.route.line];
      if (tmpGroup == null) {
        final line = complexRoute.from.route.line;
        complexRouteGroup[line] = ComplexRouteGroup(line, complexRoute);
      } else {
        tmpGroup.addTransfer(complexRoute);
      }
    });

    return RoutingResult(simpleRoutes, complexRouteGroup, origin, destination);
  }

  /// Returns `List<Connection>` near from the `Point` reference.
  List<Connection> findConnections(Point reference) {
    List tmpPoints = List();
    points.forEach((key, point) {
      tmpPoints.add({"point": point, "diff": reference.getDifference(point)});
    });

    /// Take the first 10 routes with the minimum distances
    tmpPoints.sort((a, b) => a["diff"].compareTo(b["diff"]));
    tmpPoints = tmpPoints.sublist(0, 10);

    final routes = Set<Route>();
    final connections = List<Connection>();
    tmpPoints.forEach((tmpPoint) {
      Point point = tmpPoint['point'];
      point.connections.forEach((connection) {
        if (routes.add(connection.route)) {
          connections.add(connection);
        }
      });
    });
    return connections;
  }
}

class RoutingResult {
  final Point origin, destination;
  final List<SimpleRoute> simpleRoutes;
  final Map<Line, ComplexRouteGroup> complexRoutes;

  RoutingResult(
    this.simpleRoutes,
    this.complexRoutes,
    this.origin,
    this.destination,
  );

  @override
  String toString() {
    final sb = StringBuffer(
      '\n\nresults >>>>>>\n oringe: $origin\n destino: $destination\n\n',
    );
    simpleRoutes.forEach((simple) => sb.write(simple.toString()));
    complexRoutes.forEach((key, complex) => sb.write(complex.toString()));
    return sb.toString();
  }
}

class SimpleRoute {
  final Connection from, to;
  final List<Point> points;
  final double distance;

  SimpleRoute(this.from, this.to)
      : this.distance = to.distance - from.distance,
        this.points = from.getPoints(to);

  @override
  String toString() {
    return '${from.route} \t>> ${distance.round() / 1000} kms\n';
  }
}

class ComplexRouteGroup {
  final line;
  final transfers = List<ComplexRoute>();

  ComplexRouteGroup(this.line, ComplexRoute complexRoute) {
    transfers.add(complexRoute);
  }

  addTransfer(ComplexRoute complexRoute) {
    transfers.add(complexRoute);
  }

  @override
  String toString() {
    final sb = StringBuffer();
    transfers.forEach((complexRoute) {
      sb.write(complexRoute.toString());
    });
    return 'complex >> $line ==>>\n ${sb.toString()}';
  }
}

class ComplexRoute {
  final Connection from, to;
  final Transfer transfer;
  final double distance;
  final List<Point> pointsA, pointsB;

  ComplexRoute(this.from, this.to, this.transfer)
      : this.distance = transfer.mine.distance -
            from.distance +
            to.distance -
            transfer.other.distance,
        this.pointsA = from.getPoints(transfer.mine),
        this.pointsB = transfer.other.getPoints(to);

  @override
  String toString() {
    return '\t${from.route}\t-->\t${to.route} \t>> ${distance.round() / 1000} kms\n';
  }
}

class Point {
  final int id;
  final double lat;
  final double lng;
  final connections = List<Connection>();

  Point(this.lat, this.lng) : id = 0;

  Point.fromJson(Map<String, dynamic> json)
      : id = json['IDPUNTO'],
        lat = json['lat'],
        lng = json['lng'];

  addConnection(Connection conexion) {
    connections.add(conexion);
  }

  getDifference(Point punto) {
    return ((punto.lat.abs() - lat.abs()).abs() +
            (punto.lng.abs() - lng.abs()).abs()) /
        2;
  }

  @override
  String toString() {
    return '{ lat: $lat , lng: $lng }';
  }
}

class Line {
  final int id;
  final String name;
  final routes = List<Route>();

  Line.fromJson(Map<String, dynamic> json)
      : id = json['IDLINEA'],
        name = json['NOMBRELINEA'];

  addRoute(Route route) {
    routes.add(route);
  }

  bool operator ==(o) =>
      o is Line && o.id == id && o.name == name && o.routes == routes;

  int get hashCode => id.hashCode ^ name.hashCode ^ routes.hashCode;

  @override
  String toString() {
    return name;
  }
}

class Route {
  final int id;
  final String name;
  final Line line;
  final connections = List<Connection>();
  final transfers = List<Transfer>();

  Connection tmpLast;

  Route.fromJson(Map<String, dynamic> json, this.line)
      : id = json['IDRECORRIDO'],
        name = json['NOMBRERECORRIDO'] {
    line.addRoute(this);
  }

  addConnection(Connection connection) {
    connections.add(connection);
    connection.last = tmpLast;
    tmpLast = connection;
  }

  addTransfer(Transfer transfer) {
    this.transfers.add(transfer);
  }

  @override
  String toString() {
    return '( $line : $name )';
  }
}

class Connection {
  final int id;
  final int order;
  final num distance;
  final Route route;
  final Point point;

  Connection last;

  Connection.fromJson(
    Map<String, dynamic> json,
    this.route,
    this.point,
  )   : id = json['IDCONEXION'],
        order = json['ORDEN'],
        distance = json['DISTANCE'] {
    route.addConnection(this);
    point.addConnection(this);
  }

  /// Returns `List<Point>` with the points from origin to destination.
  List<Point> getPoints(Connection to) {
    final points = List<Point>();
    Connection tmp = to;
    while (point.id != tmp.point.id) {
      points.add(tmp.point);
      tmp = tmp.last;
    }
    return points;
  }

  bool hasSameRoute(Connection destination) {
    return route.id == destination.route.id;
  }

  bool isValidRoute(Connection destino) {
    return order < destino.order;
  }
}

class Transfer {
  final Connection mine;
  final Connection other;

  Transfer(this.mine, this.other);

  bool isInMyWay(Connection origin, Connection destination) {
    return other.route.id == destination.route.id &&
        origin.order < mine.order &&
        other.order < destination.order;
  }
}
