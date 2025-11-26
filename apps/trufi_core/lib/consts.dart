import 'package:latlong2/latlong.dart';
import 'package:trufi_core/repositories/location/interfaces/i_location_search_service.dart';
import 'package:trufi_core/repositories/location/services/photon_location_search_service.dart';

class ApiConfig {
  ApiConfig._privateConstructor();
  static final ApiConfig _instance = ApiConfig._privateConstructor();
  factory ApiConfig() => _instance;

  String _baseDomain = "otp.kigali.trufi.dev";
  String _otpPath = "/otp/transmodel/v3";
  LatLng _originMap = const LatLng(-1.96617, 30.06409);
  ILocationSearchService _iLocationSearchService =
      PhotonLocationSearchService(
        photonUrl: "https://photon.komoot.io",
        queryParameters: {
          // Bounding box for Kigali, Rwanda
          // Southwest: -1.997, 29.954
          // Northeast: -1.845, 30.167
          "bbox": "29.954,-1.997,30.167,-1.845",
          "limit": "15",
          "lang": "en",
        },
      );

  String get baseDomain => _baseDomain;
  String get openTripPlannerUrl => "https://$_baseDomain$_otpPath";
  LatLng get originMap => _originMap;
  ILocationSearchService get locationSearchService => _iLocationSearchService;

  void configure({
    String? baseDomain,
    String? otpPath,
    LatLng? originMap,
    ILocationSearchService? locationSearchService,
  }) {
    _baseDomain = baseDomain ?? _baseDomain;
    _otpPath = otpPath ?? _otpPath;
    _originMap = originMap ?? _originMap;
    _iLocationSearchService = locationSearchService ?? _iLocationSearchService;
  }
}
