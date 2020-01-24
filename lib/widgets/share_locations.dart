import 'package:share/share.dart';
import 'package:trufi_core/trufi_models.dart';

String authority = 'trufi.app';
String unencodedPath = '';

void shareRoute(PlanLocation fromLocation, PlanLocation toLocation) {
  Map<String, String> queryParameters = {
    'type': 'route',
    'origin': fromLocation.name,
    'lngo': fromLocation.longitude.toString(),
    'lato': fromLocation.latitude.toString(),
    'destiny': toLocation.name,
    'lngd': toLocation.longitude.toString(),
    'latd': toLocation.latitude.toString()
  };
  Uri uriRoute = new Uri.https(authority, unencodedPath, queryParameters);
  Share.share(uriRoute.toString());
}

void shareLocation(TrufiLocation location) {
  Map<String, String> queryParameters = {
    'type': 'location',
    'description': location.description,
    'lng': location.longitude.toString(),
    'lat': location.latitude.toString(),
  };
  Uri uriLocation = new Uri.https(authority, unencodedPath, queryParameters);
  Share.share(uriLocation.toString());
}
