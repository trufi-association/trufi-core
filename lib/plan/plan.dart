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
  VisibilityFlag _visibleFlag = VisibilityFlag.gone;

  AnimationController _animationController;
  Animation<double> _animationInstructionHeight;
  Animation<double> _animationDurationHeight;
  Animation<double> _animationSummaryHeight;
  static const durationHeight = 60.0;
  static const summaryHeight = 60.0;
  static const instructionHeightMin = durationHeight + summaryHeight;
  static const instructionHeightMax = 200.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animationInstructionHeight =
        Tween(begin: instructionHeightMin, end: instructionHeightMax).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
            setState(() {});
          });
    _animationDurationHeight = Tween(begin: durationHeight, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });
    _animationSummaryHeight = Tween(
      begin: summaryHeight,
      end: instructionHeightMax,
    ).animate(
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
              child: _buildItinerariesDetails(context),
              removedChild: _buildItinerariesSummary(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItinerariesSummary(BuildContext context) {
    return StreamBuilder<PlanItinerary>(
      stream: _planPageController.outSelectedItinerary,
      initialData: _planPageController.selectedItinerary,
      builder: (
        BuildContext context,
        AsyncSnapshot<PlanItinerary> snapshot,
      ) {
        return Column(
          children: <Widget>[
            _buildTotalDurationFromSelectedItinerary(
              context,
              snapshot.data,
            ),
            _buildItinerarySummary(
              context,
              snapshot.data,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalDurationFromSelectedItinerary(
      BuildContext context, PlanItinerary itinerary) {
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    final legs = itinerary?.legs ?? [];
    var totalTime = 0.0;
    var totalDistance = 0.0;

    for (PlanItineraryLeg leg in legs) {
      totalTime += (leg.duration.ceil() / 60).ceil();
      totalDistance += leg.distance.ceil();
    }
    Color backgroundColor = Theme.of(context).primaryColor;
    return Container(
      height: _animationDurationHeight.value,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(color: backgroundColor, blurRadius: 4.0)
        ],
      ),
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Text(
            "${totalTime.ceil()} ${localizations.instructionMinutes} ",
            style: theme.textTheme.title,
          ),
          totalDistance >= 1000
              ? Text(
                  "(${(totalDistance.ceil() / 1000).ceil()} ${localizations.instructionUnitKm})",
                  style: theme.textTheme.title,
                )
              : Text(
                  "(${totalDistance.ceil()} ${localizations.instructionUnitMeter})",
                  style: theme.textTheme.title,
                ),
        ],
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
                    style: theme.textTheme.body1.copyWith(
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
    return Container(
      height: _animationSummaryHeight.value,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: <BoxShadow>[BoxShadow(blurRadius: 1.0)],
      ),
      child: Material(
        color: Theme.of(context).primaryColor,
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
                      Row(children: children),
                    ],
                  ),
                ),
                _buildToggleSummaryButton(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItinerariesDetails(BuildContext context) {
    Color backgroundColor = Theme.of(context).primaryColor;
    return Container(
      height: _animationInstructionHeight.value,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(color: backgroundColor, blurRadius: 4.0)
        ],
      ),
      child: PlanItineraryTabPages(
        _tabController,
        _planPageController.plan.itineraries,
        _buildToggleSummaryButton(context),
      ),
    );
  }

  Widget _buildToggleSummaryButton(BuildContext context) {
    return Container(
      child: GestureDetector(
        child: _visibleFlag == VisibilityFlag.visible
            ? Icon(Icons.keyboard_arrow_down)
            : Icon(Icons.keyboard_arrow_up),
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
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }
}
