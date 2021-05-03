import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/gps_location/location_provider_cubit.dart';
import 'package:trufi_core/widgets/app_review_dialog.dart';

class AppLifecycleReactor extends StatefulWidget {
  const AppLifecycleReactor({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _AppLifecycleReactorState createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final locationProviderCubit = context.read<LocationProviderCubit>();

    if (state == AppLifecycleState.resumed) {
      final appReviewBloc = BlocProvider.of<AppReviewCubit>(context);
      final packageInfo = await PackageInfo.fromPlatform();
      if (await appReviewBloc.isAppReviewAppropriate(packageInfo)) {
        showAppReviewDialog(context);
        appReviewBloc.markReviewRequestedForCurrentVersion(packageInfo);
      }
      locationProviderCubit.start();
    } else {
      locationProviderCubit.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}