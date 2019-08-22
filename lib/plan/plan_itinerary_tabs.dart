import 'package:flutter/material.dart';

import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/widgets/vertical_swipe_detector.dart';

class PlanItineraryTabPages extends StatefulWidget {
  PlanItineraryTabPages(
    this.tabController,
    this.itineraries,
  ) : assert(itineraries != null && itineraries.length > 0);

  final TabController tabController;
  final List<PlanItinerary> itineraries;

  @override
  PlanItineraryTabPagesState createState() => PlanItineraryTabPagesState();
}

class PlanItineraryTabPagesState extends State<PlanItineraryTabPages>
    with TickerProviderStateMixin {
  static const _costHeight = 60.0;
  static const _summaryHeight = 60.0;
  static const _detailHeight = 200.0;

  AnimationController _animationController;
  Animation<double> _animationCostHeight;
  Animation<double> _animationSummaryHeight;
  Animation<double> _animationDetailHeight;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    // Cost
    _animationCostHeight = Tween(
      begin: _costHeight,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() => setState(() {}));
    // Summary
    _animationSummaryHeight = Tween(
      begin: _summaryHeight,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() => setState(() {}));
    // Detail
    _animationDetailHeight = Tween(
      begin: 0.0,
      end: _detailHeight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColor,
        boxShadow: <BoxShadow>[
          BoxShadow(color: theme.primaryColor, blurRadius: 4.0)
        ],
      ),
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: height,
                  child: TabBarView(
                    controller: widget.tabController,
                    children: widget.itineraries.map<Widget>((
                      PlanItinerary itinerary,
                    ) {
                      return _buildItinerary(context, itinerary);
                    }).toList(),
                  ),
                ),
                TabPageSelector(
                  selectedColor: Theme.of(context).iconTheme.color,
                  controller: widget.tabController,
                ),
              ],
            ),
            Positioned(
              top: 4.0,
              right: 10.0,
              child: _buildExpandButton(context),
            ),
          ],
        ),
      ),
    );
  }

  _buildItinerary(BuildContext context, PlanItinerary itinerary) {
    return _isExpanded
        ? _buildItineraryExpanded(context, itinerary)
        : _buildItineraryCollapsed(context, itinerary);
  }

  // Expanded

  Widget _buildItineraryExpanded(
    BuildContext context,
    PlanItinerary itinerary,
  ) {
    final localizations = TrufiLocalizations.of(context);
    return Container(
      height: _animationDetailHeight.value,
      child: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemBuilder: (BuildContext context, int index) {
          PlanItineraryLeg leg = itinerary.legs[index];
          return Row(
            children: <Widget>[
              Icon(leg.iconData()),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: RichText(
                    text: TextSpan(
                      text: leg.toInstruction(localizations),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        itemCount: itinerary.legs.length,
      ),
    );
  }

  // Collapsed

  Widget _buildItineraryCollapsed(
    BuildContext context,
    PlanItinerary itinerary,
  ) {
    return VerticalSwipeDetector(
      onSwipeUp: () => _setIsExpanded(true),
      child: Column(
        children: <Widget>[
          _buildItineraryCost(context, itinerary),
          _buildItinerarySummary(context, itinerary),
        ],
      ),
    );
  }

  // Cost

  Widget _buildItineraryCost(
    BuildContext context,
    PlanItinerary itinerary,
  ) {
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    return Container(
      height: _animationCostHeight.value,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        boxShadow: <BoxShadow>[
          BoxShadow(color: theme.primaryColor, blurRadius: 4.0),
        ],
      ),
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Text(
            localizations.instructionDurationMinutes(itinerary.time) + " ",
            style: theme.textTheme.title,
          ),
          itinerary.distance >= 1000
              ? Text(
                  "(" + localizations.instructionDistanceKm((itinerary.distance / 1000).ceil()) + ")",
                  style: theme.textTheme.title.copyWith(color: Colors.grey),
                )
              : Text(
                  "(" + localizations.instructionDistanceMeters(itinerary.distance) + ")",
                  style: theme.textTheme.title,
                ),
        ],
      ),
    );
  }

  // Summary

  Widget _buildItinerarySummary(
    BuildContext context,
    PlanItinerary itinerary,
  ) {
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    final children = List<Widget>();
    itinerary.legs.forEach((leg) {
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
                    localizations.instructionDurationMinutes((leg.duration.ceil() / 60).ceil()),
                    style: theme.textTheme.body1,
                  ),
            leg != itinerary.legs.last
                ? Icon(Icons.keyboard_arrow_right, color: Colors.grey)
                : Container(),
          ],
        ),
      );
    });
    return Container(
      height: _animationSummaryHeight.value,
      decoration: BoxDecoration(color: theme.primaryColor),
      child: Material(
        color: theme.primaryColor,
        child: InkWell(
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Expand / Collapse

  Widget _buildExpandButton(BuildContext context) {
    return IconButton(
      icon: _isExpanded
          ? Icon(Icons.keyboard_arrow_down, color: Colors.grey)
          : Icon(Icons.keyboard_arrow_up, color: Colors.grey),
      onPressed: () => _setIsExpanded(!_isExpanded),
    );
  }

  void _setIsExpanded(bool isExpanded) {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // Getter

  double get height =>
      _animationDetailHeight.value +
      _animationCostHeight.value +
      _animationSummaryHeight.value;
}
