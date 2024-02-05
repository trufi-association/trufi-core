import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/utils/certificates_letsencrypt_android.dart';
import 'package:trufi_core/base/utils/graphql_client/hive_init.dart';
import 'package:trufi_core/base/widgets/drawer/menu/social_media_item.dart';
import 'package:trufi_core/base/widgets/screen/lifecycle_reactor_notification.dart';
import 'package:trufi_core/default_values.dart';
import 'package:trufi_core/trufi_core.dart';
import 'package:trufi_core/trufi_router.dart';
// TODO: Update example
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CertificatedLetsencryptAndroid.workAroundCertificated();
  await initHiveForFlutter();
  runApp(
    TrufiApp(
      appNameTitle: 'ExampleApp',
      blocProviders: [
        ...DefaultValues.blocProviders(
          otpEndpoint: "https://bo-cbba.sa.api.trufi-association.org/otp",
          otpGraphqlEndpoint: "https://bo-cbba.sa.api.trufi-association.org/otp/index/graphql",
          mapConfiguration: MapConfiguration(
            center: const TrufiLatLng(-17.392600, -66.158787),
          ),
          searchAssetPath: "assets/data/search.json",
          photonUrl: "https://bo-cbba.sa.api.trufi-association.org/photon",
        ),
      ],
      trufiRouter: TrufiRouter(
        routerDelegate: DefaultValues.routerDelegate(
          appName: 'ExampleApp',
          cityName: 'City',
          countryName: 'Country',
          backgroundImageBuilder: (_) {
            return Image.asset(
              'assets/images/drawer-bg.jpg',
              fit: BoxFit.cover,
            );
          },
          urlFeedback: 'https://example/feedback',
          emailContact: 'example@example.com',
          urlShareApp: 'https://example/share',
          urlSocialMedia: const UrlSocialMedia(
            urlFacebook: 'https://www.facebook.com/Example',
          ),
          shareBaseUri: Uri(
            scheme: "https",
            host: "trufi.example",
          ),
          lifecycleReactorHandler: LifecycleReactorNotifications(
            url:
                'https://api.busboy.app/static_files/notification.json',
          ),
        ),
      ),
    ),
  );
}
