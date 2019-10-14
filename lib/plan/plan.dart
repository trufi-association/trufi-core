import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' as rx;

import '../composite_subscription.dart';
import '../plan/plan_itinerary_tabs.dart';
import '../plan/plan_map.dart';
import '../trufi_models.dart';

class PlanPageController {
  PlanPageController(this.plan) {
    _subscriptions.add(
      _selectedItineraryController.listen((selectedItinerary) {
        _selectedItinerary = selectedItinerary;
      }),
    );
  }

  final Plan plan;

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

  PlanPage(this.plan) : assert(plan != null);

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
    _planPageController = PlanPageController(widget.plan);
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
    final children = <Widget>[
      Column(
        children: <Widget>[
          Expanded(
            child: PlanMapPage(planPageController: _planPageController),
          ),
          PlanItineraryTabPages(
            _tabController,
            _planPageController.plan.itineraries,
          ),
        ],
      ),
    ];
    if (_showAnimation) {
      children.add(
        Positioned.fill(
          child: FlareActor(
            "assets/images/success.flr",
            animation: "Untitled",
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
