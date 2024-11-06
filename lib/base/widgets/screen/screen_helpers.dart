import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trufi_core/base/blocs/localization/trufi_localization_cubit.dart';
import 'package:trufi_core/base/blocs/providers/uni_link_provider/uni_link_provider.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/screen/lifecycle_reactor_wrapper.dart';
import 'package:trufi_core/base/widgets/screen/transition_page.dart';

class BaseTrufiPage extends StatelessWidget {
  const BaseTrufiPage({super.key, required this.child});

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
  NoAnimationPage({
    required Widget child,
    LifecycleReactorHandler? lifecycleReactorHandler,
  }) : super(
          child: Builder(builder: (context) {
            UniLinkProvider().runService(context);
            return BaseTrufiPage(
              child: LifecycleReactorWrapper(
                lifecycleReactorHandler: lifecycleReactorHandler,
                child: (_) => child,
              ),
            );
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
  bool canPop = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    useSafeArea: useSafeArea,
    builder: (buildContext) {
      return BaseTrufiPage(
        child: PopScope(
          canPop: canPop,
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
