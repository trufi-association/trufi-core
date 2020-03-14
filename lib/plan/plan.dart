import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:trufi_core/trufi_configuration.dart';

import '../composite_subscription.dart';
import '../plan/plan_itinerary_tabs.dart';
import '../plan/plan_map.dart';
import '../trufi_models.dart';

class PlanPageController {
  PlanPageController(this.plan, this.ad) {
    _subscriptions.add(
      _selectedItineraryController.listen((selectedItinerary) {
        _selectedItinerary = selectedItinerary;
      }),
    );
  }

  final Plan plan;
  final Ad ad;

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
  final Plan plan;
  final Ad ad;

  PlanPage(this.plan, this.ad) : assert(plan != null);

  @override
  PlanPageState createState() => PlanPageState();
}

class PlanPageState extends State<PlanPage> with TickerProviderStateMixin {
  PlanPageController _planPageController;
  TabController _tabController;

  var _showAnimation = true;

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
    final cfg = TrufiConfiguration();
    final children = <Widget>[
      Column(
        children: <Widget>[
          Expanded(
            child: PlanMapPage(planPageController: _planPageController),
          ),
          PlanItineraryTabPages(
            _tabController,
            _planPageController.plan.itineraries,
            _planPageController.ad,
          ),
        ],
      ),
    ];
    if (_showAnimation && cfg.animation.success != null) {
      children.add(
        Positioned.fill(
          child: FlareActor(
            cfg.animation.success.filename,
            animation: cfg.animation.success.animation,
            callback: (animationName) {
              setState(() {
                _showAnimation = false;
              });
            },
          ),
        ),
      );
    }
    return Stack(children: children);
  }
}
