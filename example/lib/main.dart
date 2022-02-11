import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/utils/graphql_client/hive_init.dart';
import 'package:trufi_core/default_values.dart';
import 'package:trufi_core/trufi_core.dart';
import 'package:trufi_core/trufi_router.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(
    TrufiApp(
      appNameTitle: 'Example',
      blocProviders: [
        ...DefaultValues.blocProviders(
          otpEndpoint: "http://138.197.103.220:8000/otp/routers/default",
          otpGraphqlEndpoint:
              "https://otp.busboy.app/otp/routers/default/index/graphql",
          mapConfiguration: MapConfiguration(
            center: LatLng(5.825574, -73.033660),
          ),
        ),
      ],
      trufiRouter: TrufiRouter(
        routerDelegate: DefaultValues.routerDelegate(
          appName: 'Example',
          cityName: 'City - Country',
          urlFeedback: 'https://example/feedback'
        ),
      ),
    ),
  );
}
