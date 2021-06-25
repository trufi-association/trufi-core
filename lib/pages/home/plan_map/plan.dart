import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/composite_subscription.dart';
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/pages/home/plan_map/plan_map.dart';
import 'package:trufi_core/trufi_app.dart';
import 'package:trufi_core/widgets/custom_scrollable_container.dart';

import 'custom_itinerary/custom_itinerary.dart';

class PlanPageController {
  PlanPageController(this.plan, this.ad) {
    _subscriptions.add(
      _selectedItineraryController.listen((selectedItinerary) {
        _selectedItinerary = selectedItinerary;
      }),
    );
  }

  final PlanEntity plan;
  final AdEntity ad;

  final _selectedItineraryController = rx.BehaviorSubject<PlanItinerary>();
  final _subscriptions = CompositeSubscription();

  PlanItinerary _selectedItinerary;

  void dispose() {
    _selectedItineraryController.close();
    _subscriptions.cancel();
  }

  Sink<PlanItinerary> get inSelectedItinerary {
    return _selectedItineraryController.sink;
  }

  Stream<PlanItinerary> get outSelectedItinerary {
    return _selectedItineraryController.stream;
  }

  PlanItinerary get selectedItinerary => _selectedItinerary;
}

class PlanPage extends StatelessWidget {
  final PlanEntity plan;
  final AdEntity ad;
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;

  const PlanPage(
      this.plan, this.ad, this.customOverlayWidget, this.customBetweenFabWidget,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homePageState = context.watch<HomePageCubit>().state;
    return CurrentPlanPage(
      PlanPageController(plan, ad),
      customOverlayWidget,
      customBetweenFabWidget,
      key: Key('firstFetchPlan ${homePageState.isFetchingModes}'),
    );
  }
}

class CurrentPlanPage extends StatefulWidget {
  final PlanPageController planPageController;
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;

  const CurrentPlanPage(this.planPageController, this.customOverlayWidget,
      this.customBetweenFabWidget,
      {Key key})
      : super(key: key);

  @override
  CurrentPlanPageState createState() => CurrentPlanPageState();
}

class CurrentPlanPageState extends State<CurrentPlanPage>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    if (widget.planPageController.plan.itineraries.isNotEmpty) {
      widget.planPageController.inSelectedItinerary.add(
        widget.planPageController.plan.itineraries.first,
      );
    }
    _tabController = TabController(
      length: widget.planPageController.plan.itineraries.length,
      vsync: this,
    )..addListener(() {
        widget.planPageController.inSelectedItinerary.add(
          widget.planPageController.plan.itineraries[_tabController.index],
        );
      });
  }

  @override
  void dispose() {
    widget.planPageController?.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = context.read<ConfigurationCubit>().state;
    final children = <Widget>[
      CustomScrollableContainer(
        openedPosition: 200,
        body: PlanMapPage(
          planPageController: widget.planPageController,
          customOverlayWidget: widget.customOverlayWidget,
          customBetweenFabWidget: widget.customBetweenFabWidget,
          markerConfiguration: cfg.markers,
          transportConfiguration: cfg.transportConf,
        ),
        panel: CustomItinerary(
          planPageController: widget.planPageController,
        ),
      ),
    ];
    final homePageBloc = context.read<HomePageCubit>();
    if (homePageBloc.state.showSuccessAnimation &&
        cfg.animations.success != null) {
      children.add(
        Positioned.fill(
          child: FlareActor(
            cfg.animations.success.filename,
            animation: cfg.animations.success.animation,
            callback: (t) => homePageBloc.configSuccessAnimation(show: false),
          ),
        ),
      );
    }
    return Stack(children: children);
  }
}
