import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:trufi_app/composite_subscription.dart';
import 'package:trufi_app/plan/plan_itinerary_tabs.dart';
import 'package:trufi_app/plan/plan_map.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/widgets/visible.dart';

class PlanPageController {
  PlanPageController(this.plan) {
    _subscriptions.add(
      _selectedItineraryController.listen((selectedItinerary) {
        _selectedItinerary = selectedItinerary;
      }),
    );
  }

  final Plan plan;

  final _selectedItineraryController = BehaviorSubject<PlanItinerary>();
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
  VisibilityFlag _visibleFlag = VisibilityFlag.visible;

  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween(begin: 200.0, end: 60.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });
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
    _animationController.dispose();
    _planPageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              child: PlanMapPage(planPageController: _planPageController),
            ),
            VisibleWidget(
              visibility: _visibleFlag,
              child: _buildItinerariesVisible(context),
              removedChild: _buildItinerariesGone(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItinerariesVisible(BuildContext context) {
    return Container(
      height: _animation.value,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4.0)],
      ),
      child: PlanItineraryTabPages(
        _tabController,
        _planPageController.plan.itineraries,
        _buildToggleSummaryButton(context),
      ),
    );
  }

  Widget _buildItinerariesGone(BuildContext context) {
    return Container(
      height: _animation.value,
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4.0)],
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: _toggleInstructions,
          child: Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        StreamBuilder<PlanItinerary>(
                          stream: _planPageController.outSelectedItinerary,
                          initialData: _planPageController.selectedItinerary,
                          builder: (
                            BuildContext context,
                            AsyncSnapshot<PlanItinerary> snapshot,
                          ) {
                            return _buildItinerarySummary(
                              context,
                              snapshot.data,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildToggleSummaryButton(context),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildItinerarySummary(BuildContext context, PlanItinerary itinerary) {
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    final children = List<Widget>();
    final legs = itinerary?.legs ?? [];
    for (var i = 0; i < legs.length; i++) {
      final leg = legs[i];
      children.add(
        Row(
          children: <Widget>[
            Icon(leg.iconData()),
            leg.mode == 'BUS'
                ? Text(
                    leg.route,
                    style: theme.textTheme.body2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    "${(leg.duration.ceil() / 60).ceil().toString()} ${localizations.instructionMinutes}",
                    style: theme.textTheme.body1,
                  ),
            i < (legs.length - 1)
                ? Icon(Icons.keyboard_arrow_right)
                : Container(),
          ],
        ),
      );
    }
    return Row(
      children: children,
    );
  }

  Widget _buildToggleSummaryButton(BuildContext context) {
    return Container(
      child: GestureDetector(
        child: _visibleFlag == VisibilityFlag.visible
            ? Icon(Icons.keyboard_arrow_down, color: Colors.black)
            : Icon(Icons.keyboard_arrow_up, color: Colors.black),
        onTap: _toggleInstructions,
      ),
    );
  }

  void _toggleInstructions() {
    setState(() {
      _visibleFlag = _visibleFlag == VisibilityFlag.visible
          ? VisibilityFlag.gone
          : VisibilityFlag.visible;
      if (_visibleFlag == VisibilityFlag.gone) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
}
