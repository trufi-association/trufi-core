import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:trufi_core/base/blocs/localization/trufi_localization_cubit.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/screen/transition_page.dart';

class BaseTrufiPage extends StatelessWidget {
  const BaseTrufiPage({Key? key, required this.child}) : super(key: key);

  final Widget child;
  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final trufiLocalization = context.watch<TrufiLocalizationCubit>();
    return Theme(
      data: themeCubit.themeData(context),
      child: Localizations(
        locale: trufiLocalization.state.currentLocale,
        delegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          TrufiBaseLocalization.delegate,
          ...trufiLocalization.state.localizationDelegates,
        ],
        child: child,
      ),
    );
  }
}

class NoAnimationPage<T> extends TransitionPage<T> {
  NoAnimationPage({required Widget child})
      : super(
          child: Builder(builder: (context) {
            return BaseTrufiPage(child: child);
          }),
          pushTransition: PageTransition.none,
          popTransition: PageTransition.none,
        );
}

Future<T?> showTrufiDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color barrierColor = Colors.black54,
  bool barrierDismissible = true,
  bool useSafeArea = true,
  bool onWillPop = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    useSafeArea: useSafeArea,
    builder: (buildContext) {
      return BaseTrufiPage(
        child: WillPopScope(
          onWillPop: () async => onWillPop,
          child: Builder(
            builder: builder,
          ),
        ),
      );
    },
  );
}

Future<T?> showTrufiModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool isScrollControlled = false,
  bool useRootNavigator = true,
  bool isDismissible = true,
  bool enableDrag = true,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
}) async {
  return showModalBottomSheet<T>(
    context: context,
    builder: (buildContext) => BaseTrufiPage(
      child: Builder(
        builder: builder,
      ),
    ),
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    barrierColor: barrierColor,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
  );
}
