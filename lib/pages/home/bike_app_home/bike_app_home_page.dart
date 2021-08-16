import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';

import 'results_screen.dart';
import 'search_screen.dart';

class BikeAppHomePage extends StatelessWidget {
  static const String route = '/';
  const BikeAppHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homePageCubit = context.watch<HomePageCubit>();
    final homePageState = homePageCubit.state;
    final config = context.read<ConfigurationCubit>().state;
    final hasPlan =
        homePageState.plan != null && homePageState.plan.error == null;
    return Stack(
      children: [
        if (hasPlan) const ResultsScreen() else const SearchScreen(),
        if (config.animations.loading != null && homePageState.isFetching)
          Positioned.fill(child: config.animations.loading),
      ],
    );
  }
}
