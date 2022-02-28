library trufi_core;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:trufi_core/base/widgets/app_lifecycle_reactor.dart';
import 'package:trufi_core/base/blocs/localization/trufi_localization_cubit.dart';
import 'package:trufi_core/base/blocs/theme/default_theme.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';
import 'package:trufi_core/trufi_router.dart';
import 'default_values.dart';

class TrufiApp extends StatelessWidget {
  final String appNameTitle;
  final TrufiBaseTheme? trufiBaseTheme;
  final TrufiRouter trufiRouter;
  final List<BlocProvider> blocProviders;
  final TrufiLocalization _trufiLocalization;

  TrufiApp({
    Key? key,
    required this.appNameTitle,
    required this.trufiRouter,
    required this.blocProviders,
    this.trufiBaseTheme,
    TrufiLocalization? trufiLocalization,
  })  : _trufiLocalization =
            trufiLocalization ?? DefaultValues.trufiLocalization(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLifecycleReactor(
      child: MultiProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(
              themeState: trufiBaseTheme ??
                  TrufiBaseTheme(
                    themeMode: ThemeMode.system,
                    brightness: Brightness.light,
                    theme: theme,
                    darkTheme: themeDark,
                  ),
            ),
          ),
          BlocProvider<TrufiLocalizationCubit>(
            create: (context) => TrufiLocalizationCubit(
              state: _trufiLocalization,
            ),
          ),
          ...blocProviders
        ],
        child: MaterialApp.router(
          title: appNameTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          // Delegates are required when there is no context for delegates by default
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: _trufiLocalization.supportedLocales,
          debugShowCheckedModeBanner: false,
          routeInformationParser: trufiRouter.routeInformationParser,
          routerDelegate: trufiRouter.routerDelegate,
        ),
      ),
    );
  }
}
