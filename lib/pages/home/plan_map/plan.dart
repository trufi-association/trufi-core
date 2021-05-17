import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/composite_subscription.dart';
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs.dart';
import 'package:trufi_core/pages/home/plan_map/plan_map.dart';
import 'package:trufi_core/trufi_app.dart';

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

class PlanPage extends StatefulWidget {
  final PlanEntity plan;
  final AdEntity ad;
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;

  const PlanPage(
      this.plan, this.ad, this.customOverlayWidget, this.customBetweenFabWidget,
      {Key key})
      : assert(plan != null),
        super(key: key);

  @override
  PlanPageState createState() => PlanPageState();
}

class PlanPageState extends State<PlanPage> with TickerProviderStateMixin {
  PlanPageController _planPageController;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _planPageController = PlanPageController(widget.plan, widget.ad);
    if (_planPageController.plan.itineraries.isNotEmpty) {
      _planPageController.inSelectedItinerary.add(
        _planPageController.plan.itineraries.first,
      );
    }
    _tabController = TabController(
      length: _planPageController.plan.itineraries.length,
      vsync: this,
    )..addListener(() {
        _planPageController.inSelectedItinerary.add(
          _planPageController.plan.itineraries[_tabController.index],
        );
      });
    _planPageController.outSelectedItinerary.listen((selectedItinerary) {
      _tabController.animateTo(
        _planPageController.plan.itineraries.indexOf(selectedItinerary),
      );
    });
  }

  @override
  void dispose() {
    _planPageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = context.read<ConfigurationCubit>().state;
    final children = <Widget>[
      Column(
        children: <Widget>[
          Expanded(
            child: PlanMapPage(
              planPageController: _planPageController,
              customOverlayWidget: widget.customOverlayWidget,
              customBetweenFabWidget: widget.customBetweenFabWidget,
              markerConfiguration: cfg.markers,
            ),
          ),
          PlanItineraryTabPages(
            _tabController,
            _planPageController.plan.itineraries,
            _planPageController.ad,
          ),
        ],
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
