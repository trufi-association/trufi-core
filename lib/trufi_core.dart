library trufi_core;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:trufi_core/base/widgets/app_lifecycle_reactor.dart';
import 'package:trufi_core/base/blocs/localization/trufi_localization_cubit.dart';
import 'package:trufi_core/base/blocs/theme/default_theme.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';
import 'package:trufi_core/trufi_router.dart';
import 'default_values.dart';

class TrufiCore extends StatelessWidget {
  final String appNameTitle;
  final TrufiBaseTheme? trufiBaseTheme;
  final TrufiRouter trufiRouter;
  final List<BlocProvider> blocProviders;
  final TrufiLocalization? trufiLocalization;

  const TrufiCore({
    super.key,
    required this.appNameTitle,
    required this.trufiRouter,
    required this.blocProviders,
    this.trufiBaseTheme,
    this.trufiLocalization,
  });

  @override
  Widget build(BuildContext context) {
    final currentTrufiLocalization =
        trufiLocalization ?? DefaultValues.trufiLocalization();
    return AppLifecycleReactor(
      child: MultiBlocProvider(
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
              state: currentTrufiLocalization,
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
          supportedLocales: currentTrufiLocalization.supportedLocales,
          debugShowCheckedModeBanner: false,
          routeInformationParser: trufiRouter.routeInformationParser,
          routerDelegate: trufiRouter.routerDelegate,
        ),
      ),
    );
  }
}
