import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trufi_core/configuration/config_default/config_default/city_bike_config.dart';
import 'package:trufi_core/configuration/config_default/config_default/default_options.dart';
import 'package:trufi_core/configuration/config_default/config_default/default_settings.dart';
import 'package:trufi_core/configuration/config_default/config_default/transport_mode_config.dart';

class ConfigDefault {
  static final ConfigDefault _instance = ConfigDefault._internal();

  ConfigData configData;

  ConfigDefault._internal() : configData = ConfigData();

  static ConfigDefault get instance => _instance;
  static ConfigData get value => _instance.configData;

  static Future<void> loadFromRemote({
    required String jsonUrlFile,
    required ConfigData deafultConfigData,
  }) async {
    try {
      final response = await http.get(Uri.parse(jsonUrlFile));
      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        _instance.configData = ConfigData.fromJson(jsonMap);
        print('✅ Configuración cargada desde GitHub');
      } else {
        _instance.configData = deafultConfigData;
      }
    } catch (e) {
      _instance.configData = deafultConfigData;
    }
  }
}

class ConfigData {
  bool showAlertHeader;
  bool showBikeAndPublicItineraries;
  bool showBikeAndParkItineraries;
  late DefaultSettings defaultSettings;
  late DefaultOptions defaultOptions;
  int walkBoardCost;
  int walkBoardCostHigh;
  int suggestCarMinDistance;
  int suggestWalkMaxDistance;
  int suggestBikeMaxDistance;
  int suggestBikeAndPublicMinDistance;
  int suggestBikeAndParkMinDistance;
  double itineraryFiltering;
  int minTransferTime;
  int transferPenalty;
  String optimize;
  late CityBikeConfig cityBike;
  late Map<String, TransportModeConfig> transportModes;
  late Map<String, String> modeToOTP;
  List<String> modesWithNoBike;
  Map<String, List<List<List<double>>>> modePolygons;
  // custom mobile
  late Map<String, FormFactorAndDefaultMessage> formFactorsAndDefaultMessages;

  ConfigData({
    this.showAlertHeader = true,
    this.showBikeAndPublicItineraries = false,
    this.showBikeAndParkItineraries = false,
    DefaultSettings? defaultSettings,
    DefaultOptions? defaultOptions,
    this.walkBoardCost = 600,
    this.walkBoardCostHigh = 1200,
    this.suggestCarMinDistance = 2000,
    this.suggestWalkMaxDistance = 10000,
    this.suggestBikeMaxDistance = 30000,
    this.suggestBikeAndPublicMinDistance = 3000,
    this.suggestBikeAndParkMinDistance = 3000,
    this.itineraryFiltering = 1.5,
    this.minTransferTime = 120,
    this.transferPenalty = 0,
    this.optimize = "GREENWAYS",
    CityBikeConfig? cityBike,
    Map<String, TransportModeConfig>? transportModes,
    Map<String, String>? modeToOTP,
    this.modesWithNoBike = const ['BICYCLE_RENT', 'WALK'],
    this.modePolygons = const <String, List<List<List<double>>>>{},
    Map<String, FormFactorAndDefaultMessage>? formFactorsAndDefaultMessages,
  }) {
    this.defaultSettings = defaultSettings ?? DefaultSettings();
    this.defaultOptions = defaultOptions ?? DefaultOptions();
    this.cityBike = cityBike ?? CityBikeConfig();
    this.transportModes =
        transportModes ??
        {
          "bus": TransportModeConfig(
            availableForSelection: true,
            defaultValue: true,
          ),
          "tram": TransportModeConfig(
            availableForSelection: true,
            defaultValue: true,
          ),
          "rail": TransportModeConfig(
            availableForSelection: true,
            defaultValue: true,
          ),
          "subway": TransportModeConfig(
            availableForSelection: true,
            defaultValue: true,
          ),
          "airplane": TransportModeConfig(
            availableForSelection: true,
            defaultValue: true,
          ),
          "ferry": TransportModeConfig(
            availableForSelection: true,
            defaultValue: true,
          ),
          "funicular": TransportModeConfig(
            availableForSelection: false,
            defaultValue: false,
          ),
          // Keeping carpool before citybike to preserve order when merging configs.
          "carpool": TransportModeConfig(
            availableForSelection: false,
            defaultValue: false,
          ),
          "citybike": TransportModeConfig(
            availableForSelection: false,
            defaultValue: false, // Always false
          ),
        };
    this.modeToOTP = {
      "bus": "BUS",
      "tram": "TRAM",
      "rail": "RAIL",
      "subway": "SUBWAY",
      "citybike": "BICYCLE_RENT",
      "airplane": "AIRPLANE",
      "ferry": "FERRY",
      "funicular": "FUNICULAR",
      "walk": "WALK",
      if (modeToOTP != null) ...modeToOTP,
    };

    this.formFactorsAndDefaultMessages =
        formFactorsAndDefaultMessages ??
        <String, FormFactorAndDefaultMessage>{
          'bicycle': FormFactorAndDefaultMessage(
            translationKey: "sharingOperatorsBicycleHeader",
            icon: """
      <svg id="icon-icon_rental_bicycle" viewBox="0 0 283.46 283.46">   
         <g style="">    
          <path fill="#FBB800" d="M0.012,35.088c0-19.132,15.943-35.075,35.075-35.075h212.576c19.841,0,35.784,15.943,35.784,35.075   v212.576c0,19.84-15.943,35.784-35.784,35.784H35.088c-19.132,0-35.075-15.943-35.075-35.784V35.088z"/>    
          <path fill="#333" d="M182.552,129.281l9.436,24.622c3.767,9.968,9.968,19.493,14.619,24.81   c4.873,5.76,11.741-0.222,7.532-5.537c-4.653-5.76-9.746-14.399-13.29-23.48l-17.109-45.189H197.5l7.529,19.049   c1.107,2.659,2.66,3.766,5.096,3.766h18.384c2.66,0,4.432-1.329,5.096-3.543l9.304-27.026c2.214-6.203-5.318-8.859-7.754-3.545   c-7.311,16.172-22.372,13.956-27.908,7.532c-2.218-2.658-3.767-3.987-6.649-3.987h-19.794l-0.059-0.157   c0.046-0.071,0.098-0.149,0.143-0.219c4.141-6.308,5.301-8.461,6.282-13.254c0.963-4.687,0.008-9.056-2.713-12.346   c-2.939-3.55-7.29-5.783-12.607-5.677c-7.4,0.123-13.094,6.047-13.724,6.729c-1.798,1.937-1.684,4.967,0.26,6.774   c1.953,1.795,4.844,1.6,6.784-0.255c1.101-1.064,4.011-3.787,6.821-3.828c2.39-0.067,3.69,0.973,4.435,1.75   c1.116,1.17,1.835,3.39,1.288,5.487c-0.397,1.527-0.848,2.982-4.033,8.069l-0.007-0.007c-2.589,3.106-3.87,5.988-2.762,9.088   l7.959,20.766c-14.957,10.027-26.07,24.591-30.277,43.399c-2.968-1.586-6.277-2.06-10.21-1.64l-2.397,0.231L109.95,93.774   c2.449-0.666,5.265-1.234,8.719-1.45l2.88-0.222c2.878-0.222,5.093-1.993,5.093-4.652c0-2.658-1.993-4.873-5.537-4.873h-14.178   c-10.41,0-12.184-0.162-18.163-0.162c-3.545,0-5.76,1.269-5.76,3.927c0,5.538,7.309,10.633,14.176,10.633   c1.177,0,2.297-0.144,3.413-0.381l9.155,23.833l-9.243,13.761c-9.305-6.866-20.379-10.632-31.678-10.632   c-13.083,0-25.337,4.777-34.144,12.118c-0.289,0.241-2.147,1.995-2.413,2.259c-2.567,2.57-1.742,7.158,1.837,7.801   c0.336,0.059,2.156,0.568,2.489,0.647c13.603,3.279,26.505,11.627,36.789,22.69c-2.823,1.876-4.558,4.884-4.558,8.091   c0,5.76,3.767,9.747,10.192,10.41l57.812,6.204c10.854,1.108,19.715-3.544,20.601-16.835l0.221-3.102   C158.711,156.702,167.665,140.188,182.552,129.281z M113.948,131.358l12.013,31.272l-35.316,3.402L113.948,131.358z"/>    
          <path fill="#333" d="M77.687,208.618c-17.719,0-32.117-14.178-32.117-31.898c0-5.538,1.55-11.076,4.873-16.393   c-2.659-1.772-5.982-3.322-8.862-4.431c-3.765,6.204-5.76,13.735-5.76,20.824c0,23.036,18.831,41.644,41.866,41.644   c14.843,0,28.133-7.753,35.444-19.715l-11.744-1.329C96.075,204.409,87.433,208.618,77.687,208.618z"/>    
          <path fill="#333" d="M211.039,135.075c-2.66,0-5.096,0.221-7.31,0.664l3.543,9.304c1.107-0.221,2.437-0.221,3.767-0.221   c17.497,0,31.896,14.398,31.896,31.898c0,17.72-14.399,31.898-31.896,31.898c-17.721,0-31.899-14.178-31.899-31.898   c0-7.31,2.438-13.955,6.424-19.273l-3.986-10.41c-7.532,7.532-12.405,18.165-12.405,29.683c0,23.036,18.827,41.644,41.866,41.644   c23.035,0,41.645-18.608,41.645-41.644C252.684,153.682,234.074,135.075,211.039,135.075z"/>    
       </g>   
      </svg>""",
          ),
          'scooter': FormFactorAndDefaultMessage(
            translationKey: "sharingOperatorsScooterHeader",
            icon: """
      <svg id="icon-icon_rental_scooter" viewBox="0 0 32.53 32.53">   
         <g style="">    
          <path transform="scale(0.115,0.115)" fill="#ff834a" d="M0.012,35.088c0-19.132,15.943-35.075,35.075-35.075h212.576c19.841,0,35.784,15.943,35.784,35.075   v212.576c0,19.84-15.943,35.784-35.784,35.784H35.088c-19.132,0-35.075-15.943-35.075-35.784V35.088z"/>    
          <g id="g5063" fill="#fff">     
             <g transform="translate(-0.09746688,-0.3898675)" id="g4249">      
                <circle r="1.911" cy="27.102358" cx="24.294355"/>      
                <circle transform="rotate(-67.5)" r="1.911" cy="19.397024" cx="-21.300201"/>      
                <path d="m 24.633356,23.970356 a 0.46,0.46 0 0 0 0.113,-0.354 l -1.096,-11.018 h 1.303 a 0.46,0.46 0 0 0 0,-0.918 h -2.216 a 1.127,1.127 0 0 0 -1.361,-0.338 l -2.12,0.954 -1.149,-1.548 a 2.559,2.559 0 0 0 -4.486,0.717 l -1.218,3.664 3.867,1.285 0.996,-2.999 1.256,1.69 3.787,-1.708 c 0.184,-0.083 0.342,-0.215 0.458,-0.38 l 1.025,10.212 a 3.911,3.911 0 0 0 -3.17,2.561 h -7.182 a 3.908,3.908 0 0 0 -3.6719999,-2.591 0.46,0.46 0 0 0 0,0.918 2.985,2.985 0 0 1 2.9809999,2.98 c 0,0.254 0.205,0.46 0.459,0.46 h 7.645 a 0.46,0.46 0 0 0 0.46,-0.46 2.984,2.984 0 0 1 2.98,-2.98 0.46,0.46 0 0 0 0.34,-0.147 z"/>      
                <circle transform="rotate(-9.22)" r="2.5150001" cy="9.2922077" cx="16.275782"/>      
                <path d="m 13.668356,18.439356 1.863,2.02 -1.024,4.623 h 2.75 l 1.25,-5.39 -2.44,-2.65 -3.873,-1.288 -0.002,0.006 -1.953,2.92 H 5.9633561 v 2.593 h 5.8079999 z"/>      
             </g>     
          </g>    
       </g>   
      </svg>""",
          ),
          'cargo_bicycle': FormFactorAndDefaultMessage(
            translationKey: "sharingOperatorsCargoBicycleHeader",
            icon: """
      <svg id="icon-icon_rental_cargo_bicycle" viewBox="0 0 40 40">   
         <g style="">    
          <path fill="#ff834a" d="M34.923,17.462c0,9.643-7.818,17.462-17.462,17.462S0,27.105,0,17.462C0,7.818,7.817,0,17.461,0         S34.923,7.818,34.923,17.462"/>    
          <g>     
             <path fill="#fff" d="M13.722,21.528l1.605,1.673v4.507h-1.434v-3.619l-2.356-2.048c-0.272-0.183-0.409-0.524-0.409-1.025           c0-0.409,0.137-0.751,0.409-1.024l2.049-2.049c0.182-0.272,0.523-0.409,1.024-0.409c0.432,0,0.819,0.137,1.161,0.409l1.399,1.4           c0.728,0.728,1.593,1.092,2.595,1.092v1.468c-1.435,0-2.664-0.512-3.687-1.536l-0.58-0.581L13.722,21.528z"/>     
             <path fill="#fff" d="M17.171,17.875c-0.387,0-0.728-0.142-1.025-0.426c-0.295-0.285-0.443-0.62-0.443-1.007           c0-0.387,0.148-0.728,0.443-1.025c0.296-0.295,0.638-0.443,1.025-0.443c0.387,0,0.723,0.148,1.007,0.443           c0.284,0.296,0.426,0.638,0.426,1.025c0,0.387-0.142,0.723-0.426,1.007C17.894,17.732,17.558,17.875,17.171,17.875"/>     
             <path fill="#fff" d="M27.536,26.019c-0.44-0.44-0.979-0.66-1.618-0.66c-0.638,0-1.174,0.22-1.606,0.66           c-0.433,0.44-0.649,0.979-0.649,1.618s0.216,1.174,0.649,1.607c0.433,0.433,0.968,0.649,1.606,0.649           c0.639,0,1.178-0.216,1.618-0.649c0.44-0.433,0.66-0.968,0.66-1.607S27.976,26.459,27.536,26.019z M26.948,28.654           c-0.285,0.278-0.627,0.417-1.028,0.417c-0.401,0-0.741-0.139-1.019-0.417c-0.278-0.278-0.417-0.618-0.417-1.019           s0.139-0.744,0.417-1.028c0.278-0.285,0.618-0.427,1.019-0.427c0.401,0,0.744,0.142,1.028,0.427           c0.285,0.285,0.427,0.628,0.427,1.028S27.232,28.376,26.948,28.654z"/>     
             <path fill="#fff" d="M12.101,23.678c-0.695-0.705-1.554-1.058-2.578-1.058c-1.025,0-1.89,0.353-2.595,1.058           c-0.705,0.706-1.058,1.57-1.058,2.595c0,1.025,0.353,1.884,1.058,2.578c0.705,0.694,1.57,1.041,2.595,1.041           c1.024,0,1.883-0.347,2.578-1.041c0.694-0.694,1.041-1.553,1.041-2.578C13.142,25.249,12.795,24.385,12.101,23.678z M11.316,28.066           c-0.489,0.489-1.087,0.734-1.792,0.734c-0.705,0-1.308-0.245-1.809-0.734c-0.501-0.489-0.751-1.087-0.751-1.792           c0-0.705,0.25-1.309,0.751-1.809c0.501-0.501,1.104-0.751,1.809-0.751c0.705,0,1.303,0.25,1.792,0.751           c0.489,0.501,0.734,1.104,0.734,1.809C12.05,26.979,11.805,27.576,11.316,28.066z"/>     
             <path fill="#fff" d="M22.937,27.646c0-0.83,0.288-1.54,0.864-2.129c0.576-0.589,1.279-0.884,2.109-0.884           c0.542,0,1.028,0.139,1.467,0.39l1.323-2.403H16.298l1.384,5.087h5.26C22.942,27.686,22.937,27.667,22.937,27.646z"/>     
          </g>    
          <path fill="#fff" d="M17.762,2.758c2.786-0.022,5.062,2.219,5.083,5.005c0.022,2.786-2.219,5.062-5.005,5.083         c-1.364,0.011-2.673-0.531-3.631-1.502l0.794-0.816c0.719,0.752,1.718,1.171,2.758,1.159c1.045,0.013,2.049-0.402,2.78-1.148         c1.529-1.505,1.549-3.965,0.044-5.494c-0.014-0.015-0.029-0.029-0.044-0.044c-0.732-0.744-1.736-1.155-2.78-1.138         c-2.158-0.006-3.911,1.738-3.917,3.896c0,0.004,0,0.007,0,0.011h1.685l-2.265,2.254V9.949l-2.146-2.146h1.685         c-0.006-2.78,2.243-5.038,5.023-5.044c0.007,0,0.014,0,0.022,0L17.762,2.758z M17.204,5.57h0.848v2.361l1.964,1.181l-0.419,0.687         L17.204,8.35L17.204,5.57z"/>    
       </g>   
      </svg>""",
          ),
          'car': FormFactorAndDefaultMessage(
            translationKey: "sharingOperatorsCarHeader",
            icon: """
            <svg id="icon-icon_rental_car" viewBox="0 0 32.53 32.53">
               <g style="">
                <path fill="#ff834a" d="M320.34 384.05a16.27 16.27 0 11-16.26-16.27 16.26 16.26 0 0116.26 16.27" transform="translate(-287.81 -367.78)"/>
                <path fill="#fff" d="M304.35 370.35a4.7 4.7 0 11-3.3 8l.73-.76a3.5 3.5 0 002.57 1.08 3.56 3.56 0 002.59-1.07 3.62 3.62 0 000-5.16 3.55 3.55 0 00-2.59-1.06 3.64 3.64 0 00-3.65 3.64h1.57l-2.1 2.1-.05-.07-2-2h1.56a4.69 4.69 0 014.7-4.7zm-.51 2.62h.78v2.2l1.83 1.1-.39.64-2.22-1.35zM312 385.46a.67.67 0 00-.24 0l-.83.23-.89-2.16a2 2 0 00-1.75-1.17h-8.38a2 2 0 00-1.75 1.17l-.88 2.15-.83-.22a.67.67 0 00-.24 0 .73.73 0 00-.73.78v.46a1 1 0 00.95.95h.06l-.13.31a7 7 0 00-.45 2.26v4.31a1 1 0 00.95 1H298a1 1 0 00.95-1v-1.06h10.28v1.06a1 1 0 001 1h1.15a1 1 0 00.95-1v-4.31a7 7 0 00-.45-2.26l-.13-.31h.08a1 1 0 00.95-.95v-.46a.74.74 0 00-.78-.78zm-14.05 1.66l1.35-3.28a1.22 1.22 0 011-.71h7.52a1.23 1.23 0 011.05.71l1.34 3.28a.47.47 0 01-.47.7h-11.35a.47.47 0 01-.47-.7zm.6 4.71a1.23 1.23 0 111.22-1.23 1.23 1.23 0 01-1.25 1.23zm11.22 0a1.23 1.23 0 111.23-1.23 1.23 1.23 0 01-1.26 1.23z" transform="translate(-287.81 -367.78)"/>
             </g>
            </svg>""",
          ),
        };
  }
  factory ConfigData.fromJson(Map<String, dynamic> json) {
    return ConfigData(
      showAlertHeader: json['showAlertHeader'] ?? true,
      showBikeAndPublicItineraries:
          json['showBikeAndPublicItineraries'] ?? false,
      showBikeAndParkItineraries: json['showBikeAndParkItineraries'] ?? false,
      defaultSettings:
          json['defaultSettings'] != null
              ? DefaultSettings.fromJson(json['defaultSettings'])
              : null,
      defaultOptions:
          json['defaultOptions'] != null
              ? DefaultOptions.fromJson(json['defaultOptions'])
              : null,
      walkBoardCost: json['walkBoardCost'] ?? 600,
      walkBoardCostHigh: json['walkBoardCostHigh'] ?? 1200,
      suggestCarMinDistance: json['suggestCarMinDistance'] ?? 2000,
      suggestWalkMaxDistance: json['suggestWalkMaxDistance'] ?? 10000,
      suggestBikeMaxDistance: json['suggestBikeMaxDistance'] ?? 30000,
      suggestBikeAndPublicMinDistance:
          json['suggestBikeAndPublicMinDistance'] ?? 3000,
      suggestBikeAndParkMinDistance:
          json['suggestBikeAndParkMinDistance'] ?? 3000,
      itineraryFiltering: (json['itineraryFiltering'])?.toDouble() ?? 1.5,
      minTransferTime: json['minTransferTime'] ?? 120,
      transferPenalty: json['transferPenalty'] ?? 0,
      optimize: json['optimize'] ?? 'GREENWAYS',
      cityBike:
          json['cityBike'] != null
              ? CityBikeConfig.fromJson(json['cityBike'])
              : null,
      transportModes: (json['transportModes'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, TransportModeConfig.fromJson(value)),
      ),
      modeToOTP: (json['modeToOTP'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      modesWithNoBike:
          (json['modesWithNoBike'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['BICYCLE_RENT', 'WALK'],
      modePolygons:
          (json['modePolygons'] as Map<String, dynamic>?)?.map((key, value) {
            final parsed =
                (value as List)
                    .map(
                      (outer) =>
                          (outer as List)
                              .map(
                                (inner) =>
                                    (inner as List)
                                        .map(
                                          (coord) => (coord as num).toDouble(),
                                        )
                                        .toList(),
                              )
                              .toList(),
                    )
                    .toList();
            return MapEntry(key, parsed);
          }) ??
          {},
      formFactorsAndDefaultMessages:
          (json['formFactorsAndDefaultMessages'] as Map<String, dynamic>?)?.map(
            (key, value) =>
                MapEntry(key, FormFactorAndDefaultMessage.fromJson(value)),
          ),
    );
  }
}

class FormFactorAndDefaultMessage {
  String translationKey;
  String? icon;

  FormFactorAndDefaultMessage({required this.translationKey, this.icon});

  factory FormFactorAndDefaultMessage.fromJson(Map<String, dynamic> json) {
    return FormFactorAndDefaultMessage(
      translationKey: json['translationKey'] ?? '',
      icon: json['icon'],
    );
  }
}
