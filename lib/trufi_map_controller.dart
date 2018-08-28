import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/trufi_models.dart';

typedef void OnSelected(PlanItinerary itinerary);

class MapControllerPage extends StatefulWidget {
  final Plan plan;
  final OnSelected onSelected;

  MapControllerPage({this.plan, this.onSelected});

  @override
  MapControllerPageState createState() {
    return new MapControllerPageState();
  }
}

class MapControllerPageState extends State<MapControllerPage> {
  MapController mapController;
  Map<PlanItinerary, List<Polyline>> _itineraries;
  PlanItinerary _selectedItinerary;
  List<Marker> _markers = <Marker>[];
  List<Polyline> _polylines = <Polyline>[];

  void initState() {
    super.initState();
    mapController = new MapController();
  }

  Widget build(BuildContext context) {
    Plan plan = widget.plan;
    _itineraries = Map();
    _markers = List();
    _polylines = List();
    var bounds = LatLngBounds();
    if (plan != null) {
      if (plan.from != null) {
        _markers.add(createFromMarker(createLatLngWithPlanLocation(plan.from)));
      }
      if (plan.to != null) {
        _markers.add(createToMarker(createLatLngWithPlanLocation(plan.to)));
      }
      if (plan.itineraries.isNotEmpty) {
        if (_selectedItinerary == null ||
            !plan.itineraries.contains(_selectedItinerary)) {
          _selectedItinerary = plan.itineraries.first;
        }
        _itineraries = createItineraries(plan, _selectedItinerary);
        _itineraries.forEach((_, polylines) => _polylines.addAll(polylines));
      }
    }
    _markers.forEach((marker) => bounds.extend(marker.point));
    _polylines.forEach((polyline) {
      polyline.points.forEach((point) {
        bounds.extend(point);
      });
    });
    if (bounds.isValid) {
      mapController.fitBounds(bounds);
    }

    return new Padding(
      padding: new EdgeInsets.all(0.0),
      child: new Column(
        children: [
          new Flexible(
            child: new FlutterMap(
              mapController: mapController,
              options: new MapOptions(
                zoom: 5.0,
                maxZoom: 19.0,
                minZoom: 1.0,
                onTap: (point) => _mapTap(point),
              ),
              layers: [
                _mapBoxTileLayerOptions(),
                new PolylineLayerOptions(polylines: _polylines),
                new MarkerLayerOptions(markers: _markers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _openStreetMapTileLayerOptions() {
    return new TileLayerOptions(
        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ['a', 'b', 'c']);
  }

  _mapBoxTileLayerOptions() {
    return new TileLayerOptions(
      urlTemplate: "https://api.tiles.mapbox.com/v4/"
          "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
      additionalOptions: {
        'accessToken':
            'pk.eyJ1IjoicmF4ZGEiLCJhIjoiY2plZWI4ZGNtMDhjdDJ4cXVzbndzdjJrdCJ9.glZextqSSPedd2MudTlMbQ',
        'id': 'mapbox.streets',
      },
    );
  }

  _mapTap(LatLng point) {
    Polyline polyline = polylineHitTest(_polylines, point);
    if (polyline != null) {
      setState(() {
        _selectedItinerary = _itineraryForPolyline(polyline);
        if (widget.onSelected != null) {
          widget.onSelected(_selectedItinerary);
        }
      });
    }
  }

  PlanItinerary _itineraryForPolyline(Polyline polyline) {
    MapEntry<PlanItinerary, List<Polyline>> entry =
        _itineraryEntryForPolyline(polyline);
    return entry != null ? entry.key : null;
  }

  MapEntry<PlanItinerary, List<Polyline>> _itineraryEntryForPolyline(
      Polyline polyline) {
    return _itineraries.entries.firstWhere(
        (pair) =>
            pair.value.firstWhere((p) => p == polyline, orElse: () => null) !=
            null,
        orElse: () => null);
  }
}

LatLng createLatLngWithPlanLocation(PlanLocation location) {
  return LatLng(location.latitude, location.longitude);
}

Marker createFromMarker(LatLng latLng) {
  return createMarker(latLng, Icons.gps_fixed, AnchorPos.center, Colors.blue);
}

Marker createToMarker(LatLng latLng) {
  return createMarker(latLng, Icons.location_on, AnchorPos.top, Colors.red);
}

Marker createMarker(
    LatLng latLng, IconData iconData, AnchorPos anchor, Color color) {
  return new Marker(
    point: latLng,
    anchor: anchor,
    builder: (context) =>
        new Container(child: new Icon(iconData, color: color)),
  );
}

Map<PlanItinerary, List<Polyline>> createItineraries(
    Plan plan, PlanItinerary selectedItinerary) {
  Map<PlanItinerary, List<Polyline>> itineraries = Map();
  plan.itineraries.forEach((itinerary) {
    List<Polyline> polylines = List();
    bool isSelected = itinerary == selectedItinerary;
    itinerary.legs.forEach((leg) {
      List<LatLng> points = decodePolyline(leg.points);
      Polyline polyline = new Polyline(
          points: points,
          color: isSelected
              ? leg.mode == 'WALK' ? Colors.blue : Colors.green
              : Colors.grey,
          strokeWidth: isSelected ? 6.0 : 3.0);
      polylines.add(polyline);
    });
    itineraries.addAll({itinerary: polylines});
  });
  return itineraries;
}

List<LatLng> decodePolyline(String encoded) {
  List<LatLng> points = new List<LatLng>();
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;
  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;
    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    LatLng p = new LatLng(lat / 1E5, lng / 1E5);
    points.add(p);
  }
  return points;
}

Polyline polylineHitTest(List<Polyline> polylines, LatLng point) {
  Polyline minPolyline;
  double minDist = double.maxFinite;
  polylines.forEach((p) {
    for (int i = 0; i < p.points.length - 1; i++) {
      double dist = distToSegment(point, p.points[i], p.points[i + 1]);
      if (dist < minDist) {
        minDist = dist;
        minPolyline = p;
      }
    }
  });
  return minPolyline;
}

double sqr(double x) {
  return x * x;
}

double dist2(LatLng v, LatLng w) {
  return sqr(v.longitude - w.longitude) + sqr(v.latitude - w.latitude);
}

double distToSegment(LatLng p, LatLng v, LatLng w) {
  return sqrt(distToSegmentSquared(p, v, w));
}

double distToSegmentSquared(LatLng p, LatLng v, LatLng w) {
  double l2 = dist2(v, w);
  if (l2 == 0) return dist2(p, v);
  double t = ((p.longitude - v.longitude) * (w.longitude - v.longitude) +
          (p.latitude - v.latitude) * (w.latitude - v.latitude)) /
      l2;
  t = max(0.0, min(1.0, t));
  return dist2(
      p,
      LatLng(v.latitude + t * (w.latitude - v.latitude),
          v.longitude + t * (w.longitude - v.longitude)));
}
