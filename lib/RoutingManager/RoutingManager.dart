import 'dart:convert';
import 'dart:io';

class RoutingManager {
  Map<int, Punto> puntos = new Map();
  Map<int, Linea> lineas = new Map();
  Map<int, Recorrido> recorridos = new Map();
  Map<int, Conexion> conexiones = new Map();

  RoutingManager() {
    load();
  }

  /// load from json files
  void load() {
    json
        .decode(new File('assets/data/base/puntos.json').readAsStringSync())
        .forEach((json) => puntos[json['IDPUNTO']] = new Punto.fromJson(json));
    json
        .decode(new File('assets/data/base/lineas.json').readAsStringSync())
        .forEach((json) => lineas[json['IDLINEA']] = new Linea.fromJson(json));
    json
        .decode(new File('assets/data/base/recorridos.json').readAsStringSync())
        .forEach((json) => recorridos[json['IDRECORRIDO']] =
            new Recorrido.fromJson(json, lineas[json['IDLINEA']]));
    json
        .decode(new File('assets/data/base/conexiones.json').readAsStringSync())
        .forEach((json) {
      conexiones[json['IDCONEXION']] = new Conexion.fromJson(
          json, recorridos[json['IDRECORRIDO']], puntos[json['IDPUNTO']]);
    });
    json
        .decode(
            new File('assets/data/base/transbordos.json').readAsStringSync())
        .forEach((json) {
      recorridos[json['IDRECORRIDO']].add_transbordo(
          new Transbordo(conexiones[json['MINE']], conexiones[json['OTHER']]));
    });
  }

  /// The [params] are latitude and longitude from oringin and detiny.
  ///
  /// Returns `RoutingResult` with simple and complex list routes.
  RoutingResult find_routes(
      double olat, double olng, double dlat, double dlng) {
    Punto origen = new Punto(olat, olng);
    Punto destino = new Punto(dlat, dlng);

    List<Conexion> lista_origen = find_connections(origen);
    List<Conexion> lista_destino = find_connections(destino);

    List<RutaSimple> simples = new List();
    List<RutaCompleja> complejos = new List();

    /// find common routes
    lista_origen.forEach((origen_connection) {
      lista_destino.forEach((destino_connection) {
        if (origen_connection.has_same_recorrido(destino_connection)) {
          if (origen_connection.is_valid_route(destino_connection)) {
            /// if the origin and destiny has the same route and it is valid
            simples.add(new RutaSimple(origen_connection, destino_connection));
          }
        } else {
          origen_connection.recorrido.transbordos.forEach((transbordo) {
            if (transbordo.is_in_my_way(
                origen_connection, destino_connection)) {
              complejos.add(new RutaCompleja(
                  origen_connection, destino_connection, transbordo));
            }
          });
        }
      });
    });

    /// sort simple results by distances
    simples.sort((a, b) => a.distance.compareTo(b.distance));

    /// this part is for reduce results
    if (simples.length > 20) {
      simples = simples.sublist(0, 20);
      complejos = new List();
    } else if (complejos.length > 20) {
      /// sort complex  results by total distances
      complejos.sort((a, b) => a.distance.compareTo(b.distance));
      complejos = complejos.sublist(0, 20);
    }

    /// format complex result grouped by linea
    Map<Linea, RutaComplejaGrupo> grupo_complejo = new Map();
    complejos.forEach((complejo) {
      RutaComplejaGrupo tmp_grupo =
          grupo_complejo[complejo.desde.recorrido.linea];
      if (tmp_grupo == null) {
        grupo_complejo[complejo.desde.recorrido.linea] =
            new RutaComplejaGrupo(complejo);
      } else {
        tmp_grupo.add_transbordos(complejo);
      }
    });

    return new RoutingResult(simples, grupo_complejo, origen, destino);
  }

  /// Returns `List<Conexion>` near from the `Punto` reference.
  List<Conexion> find_connections(Punto referencia) {
    List tmp_puntos = new List();
    puntos.forEach((key, punto) {
      tmp_puntos
          .add({"punto": punto, "diff": referencia.get_difference(punto)});
    });
    tmp_puntos.sort((a, b) => a["diff"].compareTo(b["diff"]));

    /// take the first 10 routes with the minimum distances
    tmp_puntos = tmp_puntos.sublist(0, 10);

    Set<Recorrido> list_set = new Set();
    List<Conexion> res_conexiones = new List();

    tmp_puntos.forEach((tmp_punto) {
      Punto punto = tmp_punto['punto'];
      punto.conexiones.forEach((conexion) {
        if (list_set.add(conexion.recorrido)) res_conexiones.add(conexion);
      });
    });

    return res_conexiones;
  }
}

class RoutingResult {
  Punto origen, destino;
  List<RutaSimple> simples;
  Map<Linea, RutaComplejaGrupo> complejos;

  RoutingResult(List<RutaSimple> simples,
      Map<Linea, RutaComplejaGrupo> complejos, Punto origen, Punto destino)
      : this.simples = simples,
        this.complejos = complejos,
        this.origen = origen,
        this.destino = destino;

  @override
  String toString() {
    String res = '\n\nresults >>>>>>\n oringe: $origen\n destino: $destino\n\n';
    simples.forEach((simple) => res += simple.toString());
    complejos.forEach((key, complejo) => res += complejo.toString());
    return res;
  }
}

class RutaSimple {
  Conexion desde, hasta;
  List<Punto> route;
  double distance;

  RutaSimple(Conexion desde, Conexion hasta) {
    this.desde = desde;
    this.hasta = hasta;
    this.distance = hasta.distance - desde.distance;
    this.route = desde.get_route(hasta);
  }

  @override
  String toString() {
    return '${desde.recorrido} \t>> ${distance.round() / 1000} kms\n';
  }
}

class RutaComplejaGrupo {
  Linea linea;
  List<RutaCompleja> transbordos = new List();

  RutaComplejaGrupo(RutaCompleja rutacompleja) {
    this.linea = rutacompleja.desde.recorrido.linea;
    transbordos.add(rutacompleja);
  }

  add_transbordos(RutaCompleja rutacompleja) {
    transbordos.add(rutacompleja);
  }

  @override
  String toString() {
    String res = '';
    transbordos.forEach((compljeo) {
      res += compljeo.toString();
    });
    return 'complejo >> $linea ==>>\n $res';
  }
}

class RutaCompleja {
  Conexion desde, hasta;
  Transbordo transbordo;
  double distance;

  List<Punto> routea, routeb;
  RutaCompleja(Conexion desde, Conexion hasta, Transbordo transbordo) {
    this.desde = desde;
    this.hasta = hasta;
    this.transbordo = transbordo;
    this.distance = transbordo.mine.distance -
        desde.distance +
        hasta.distance -
        transbordo.other.distance;
    this.routea = desde.get_route(transbordo.mine);
    this.routeb = transbordo.other.get_route(hasta);
  }

  @override
  String toString() {
    // TODO: implement toString
    return '\t${desde.recorrido}\t-->\t${hasta.recorrido} \t>> ${distance.round() / 1000} kms\n';
  }
}

class Punto {
  int id;
  double lat;
  double lng;

  List<Conexion> conexiones = new List();
  Punto(lat, lng)
      : this.lat = lat,
        this.lng = lng;
  Punto.fromJson(Map<String, dynamic> json)
      : id = json['IDPUNTO'],
        lat = json['lat'],
        lng = json['lng'];

  add_conexion(Conexion conexion) {
    conexiones.add(conexion);
  }

  get_difference(Punto punto) {
    return ((punto.lat.abs() - lat.abs()).abs() +
            (punto.lng.abs() - lng.abs()).abs()) /
        2;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '{ lat: $lat , lng: $lng }';
  }
}

class Linea {
  int id;
  String nombre;
  List<Recorrido> recorridos = new List();

  Linea.fromJson(Map<String, dynamic> json)
      : id = json['IDLINEA'],
        nombre = json['NOMBRELINEA'];

  add_recorrido(Recorrido recorrido) {
    this.recorridos.add(recorrido);
  }

  @override
  String toString() {
    // TODO: implement toString
    return nombre;
  }
}

class Recorrido {
  int id;
  String nombre;
  Linea linea;
  List<Conexion> conexiones = new List();
  List<Transbordo> transbordos = new List();
  Conexion tmp_last;

  Recorrido.fromJson(Map<String, dynamic> json, Linea linea) {
    id = json['IDRECORRIDO'];
    nombre = json['NOMBRERECORRIDO'];
    this.linea = linea;
    linea.add_recorrido(this);
  }

  add_conexion(Conexion conexion) {
    conexiones.add(conexion);
    conexion.last = tmp_last;
    tmp_last = conexion;
  }

  add_transbordo(Transbordo transbordo) {
    this.transbordos.add(transbordo);
  }

  @override
  String toString() {
    // TODO: implement toString
    return '( ${linea} : $nombre )';
  }
}

class Conexion {
  int id;
  int orden;
  num distance;
  Recorrido recorrido;
  Punto punto;
  Conexion last;

  Conexion.fromJson(
      Map<String, dynamic> json, Recorrido recorrido, Punto punto) {
    id = json['IDCONEXION'];
    orden = json['ORDEN'];
    distance = json['DISTANCE'];
    this.recorrido = recorrido;
    this.punto = punto;
    recorrido.add_conexion(this);
    punto.add_conexion(this);
  }

  /// Returns `List<Punto>` with the points from  origin to destiny.
  List<Punto> get_route(Conexion hasta) {
    List<Punto> res = new List();
    Conexion tmp = hasta;
    while (punto.id != tmp.punto.id) {
      res.add(tmp.punto);
      tmp = tmp.last;
    }
    return res;
  }

  bool has_same_recorrido(Conexion destino) {
    return recorrido.id == destino.recorrido.id;
  }

  bool is_valid_route(Conexion destino) {
    return orden < destino.orden;
  }
}

class Transbordo {
  Conexion mine;
  Conexion other;

  Transbordo(Conexion mine, Conexion other)
      : this.mine = mine,
        this.other = other;

  bool is_in_my_way(Conexion origen, Conexion destino) {
    return other.recorrido.id == destino.recorrido.id &&
        origen.orden < mine.orden &&
        other.orden < destino.orden;
  }
}
