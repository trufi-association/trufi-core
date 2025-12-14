import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_storage/trufi_core_storage.dart';

import '../l10n/home_screen_localizations.dart';
import 'config/home_screen_config.dart';
import 'cubit/route_planner_cubit.dart';
import 'repository/hive_home_screen_repository.dart';
import 'repository/home_screen_repository.dart';
import 'services/request_plan_service.dart';
import 'services/routing_request_plan_service.dart';
import 'widgets/home_screen.dart';

/// Home screen module for TrufiApp integration.
class HomeScreenTrufiScreen extends TrufiScreen {
  final HomeScreenConfig config;
  late final HomeScreenRepository _repository;
  late final RequestPlanService _requestService;

  /// Callback when itinerary details are requested.
  final void Function(routing.Itinerary itinerary)? onItineraryDetails;

  /// Static initialization for the module.
  /// Call this once at app startup before using any HomeScreen functionality.
  static Future<void> init() async {
    await TrufiHive.ensureInitialized();
  }

  HomeScreenTrufiScreen({
    required this.config,
    HomeScreenRepository? repository,
    RequestPlanService? requestService,
    this.onItineraryDetails,
  }) {
    _repository = repository ?? HiveHomeScreenRepository();
    _requestService =
        requestService ??
        RoutingRequestPlanService(
          routing.OtpConfiguration(endpoint: config.otpEndpoint),
        );
  }

  @override
  String get id => 'home';

  @override
  String get path => '/';

  @override
  Widget Function(BuildContext context) get builder => (context) {
    return HomeScreen(
      onMenuPressed: () {
        Scaffold.of(context).openDrawer();
      },
      config: config,
      onItineraryDetails: onItineraryDetails,
    );
  };

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
    ...HomeScreenLocalizations.localizationsDelegates,
  ];

  @override
  List<Locale> get supportedLocales => HomeScreenLocalizations.supportedLocales;

  @override
  List<SingleChildWidget> get providers => [
    BlocProvider<RoutePlannerCubit>(
      create: (_) => RoutePlannerCubit(
        repository: _repository,
        requestService: _requestService,
      )..initialize(),
    ),
  ];

  @override
  ScreenMenuItem? get menuItem =>
      const ScreenMenuItem(icon: Icons.home, order: 0);

  @override
  bool get hasOwnAppBar => true; // Home usa SearchLocationBar como su AppBar

  @override
  String getLocalizedTitle(BuildContext context) {
    return HomeScreenLocalizations.of(context).menuHome;
  }

  @override
  Future<void> initialize() async {
    await _repository.initialize();
  }

  @override
  Future<void> dispose() async {
    await _repository.dispose();
  }
}
