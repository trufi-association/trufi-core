import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/utils/graphql_client/hive_init.dart';
import 'package:trufi_core/base/widgets/drawer/menu/social_media_item.dart';
import 'package:trufi_core/default_values.dart';
import 'package:trufi_core/trufi_core.dart';
import 'package:trufi_core/trufi_router.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(
    TrufiApp(
      appNameTitle: 'Trufi app',
      blocProviders: [
        ...DefaultValues.blocProviders(
          otpEndpoint: "https://api.trufi.app/otp/routers/default",
          otpGraphqlEndpoint:
              "https://otp.busboy.app/otp/routers/default/index/graphql",
          mapConfiguration: MapConfiguration(
            center: LatLng(-17.39000, -66.15400),
          ),
        ),
      ],
      trufiRouter: TrufiRouter(
        routerDelegate: DefaultValues.routerDelegate(
          appName: 'Trufi',
          cityName: 'Cochabamba - Bolivia',
          urlFeedback:
              'https://trufifeedback.z15.web.core.windows.net/route.html',
          urlShareApp: 'https://appurl.io/BOPP7QnKX',
          urlSocialMedia: const UrlSocialMedia(
              urlFacebook: 'https://www.facebook.com/TrufiAssoc'),
        ),
      ),
    ),
  );
}
