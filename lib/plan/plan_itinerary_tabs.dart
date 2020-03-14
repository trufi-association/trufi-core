import 'package:flutter/material.dart';

import '../trufi_localizations.dart';
import '../trufi_models.dart';
import '../widgets/vertical_swipe_detector.dart';

class PlanItineraryTabPages extends StatefulWidget {
  PlanItineraryTabPages(
    this.tabController,
    this.itineraries,
    this.ad,
  ) : assert(itineraries != null && itineraries.length > 0);

  final TabController tabController;
  final List<PlanItinerary> itineraries;
  final Ad ad;

  @override
  PlanItineraryTabPagesState createState() => PlanItineraryTabPagesState();
}

class PlanItineraryTabPagesState extends State<PlanItineraryTabPages>
    with TickerProviderStateMixin {
  static const _costHeight = 40.0;
  static const _summaryHeight = 40.0;
  static const _detailHeight = 200.0;
  static const _paddingHeight = 20.0;

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
                      return _buildItinerary(context, itinerary, widget.ad);
                    }).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: TabPageSelector(
                    selectedColor: Theme.of(context).primaryIconTheme.color,
                    controller: widget.tabController,
                  ),
                )
              ],
            ),
            Positioned(
              top: 4.0,
              right: 0.0,
              child: _buildExpandButton(context),
            ),
          ],
        ),
      ),
    );
  }

  _buildItinerary(BuildContext context, PlanItinerary itinerary, Ad ad) {
    return _isExpanded
        ? _buildItineraryExpanded(context, itinerary, ad)
        : _buildItineraryCollapsed(context, itinerary, ad);
  }

  // Expanded

  Widget _buildItineraryExpanded(
    BuildContext context,
    PlanItinerary itinerary,
    Ad ad,
  ) {
    final theme = Theme.of(context);
    final localization = TrufiLocalizations.of(context).localization;

    return Container(
      height: _animationDetailHeight.value,
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: _paddingHeight / 2,
          bottom: _paddingHeight / 2,
          left: 10.0,
          right: 32.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          if (ad != null && index >= itinerary.legs.length) {
            return Row(
              children: <Widget>[
                Icon(Icons.sentiment_very_satisfied, color: Theme.of(context).accentColor),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                          text: ad.text,
                          style: TextStyle(
                            color: Theme.of(context).accentColor
                          )
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          PlanItineraryLeg leg = itinerary.legs[index];
          return Row(
            children: <Widget>[
              Icon(leg.iconData(), color: theme.primaryIconTheme.color),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      text: leg.toInstruction(localization),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        itemCount: itinerary.legs.length + (ad != null ? 1 : 0),
      ),
    );
  }

  // Collapsed

  Widget _buildItineraryCollapsed(
    BuildContext context,
    PlanItinerary itinerary,
    Ad ad,
  ) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return VerticalSwipeDetector(
      onSwipeUp: () => _setIsExpanded(true),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: _paddingHeight / 2),
        child: Flex(
          direction: isPortrait ? Axis.vertical : Axis.horizontal,
          children: <Widget>[
            _buildItineraryCost(context, itinerary),
            Expanded(child: _buildItinerarySummary(context, itinerary, ad)),
          ],
        ),
      ),
    );
  }

  // Cost

  Widget _buildItineraryCost(
    BuildContext context,
    PlanItinerary itinerary,
  ) {
    final theme = Theme.of(context);
    final localization = TrufiLocalizations.of(context).localization;
    return Container(
      height: _animationCostHeight.value,
      padding: EdgeInsets.only(left: 16.0, right: 10.0),
      child: Row(
        children: <Widget>[
          Text(
            localization.instructionDurationMinutes(itinerary.time) + " ",
            style: theme.primaryTextTheme.title,
          ),
          Text(
            "(" +
                (itinerary.distance >= 1000
                    ? localization.instructionDistanceKm(
                        (itinerary.distance / 1000).ceil())
                    : localization
                        .instructionDistanceMeters(itinerary.distance)) +
                ")",
            style: theme.primaryTextTheme.title.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Summary

  Widget _buildItinerarySummary(
    BuildContext context,
    PlanItinerary itinerary,
    Ad ad,
  ) {
    final theme = Theme.of(context);
    final localization = TrufiLocalizations.of(context).localization;
    final children = List<Widget>();
    itinerary.legs.forEach((leg) {
      children.add(
        Row(
          children: <Widget>[
            Icon(leg.iconData(), color: theme.primaryIconTheme.color),
            leg.mode == 'BUS'
                ? Text(
              " " + leg.route,
              style: theme.primaryTextTheme.body1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
                : Text(
              localization.instructionDurationMinutes(
                  (leg.duration.ceil() / 60).ceil()),
              style: theme.primaryTextTheme.body1,
            ),
            ad != null ||
                leg != itinerary.legs.last
                ? Icon(Icons.keyboard_arrow_right, color: Colors.grey)
                : Container(),
          ],
        ),
      );
    });

    if (ad != null) {
      children.add(
        Row(
          children: <Widget>[
            Icon(Icons.sentiment_very_satisfied, color: Theme
                .of(context)
                .accentColor),
          ],
        ),
      );
    }

    return Container(
      height: _animationSummaryHeight.value,
      decoration: BoxDecoration(color: theme.primaryColor),
      child: Material(
        color: theme.primaryColor,
        child: InkWell(
          child: Container(
            padding: EdgeInsets.only(left: 12.0, right: 10.0),
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
          ? Icon(Icons.keyboard_arrow_down)
          : Icon(Icons.keyboard_arrow_up),
      color: Theme.of(context).primaryIconTheme.color,
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

  double get height {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    var height = _animationDetailHeight.value +
        _animationCostHeight.value +
        _paddingHeight;

    if (isPortrait) {
      height += _animationSummaryHeight.value;
    }

    return height;
  }
}
