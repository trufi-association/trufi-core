import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/theme_bloc.dart';

import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs/itinerary_details_collapsed.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs/itinerary_details_expanded.dart';

class PlanItineraryTabList extends StatefulWidget {
  final TabController tabController;
  final List<PlanItinerary> itineraries;

  PlanItineraryTabList(this.tabController, this.itineraries,
      {Key key})
      : assert(itineraries != null && itineraries.isNotEmpty),
        super(key: key);

  @override
  _PlanItineraryTabPagesState createState() => _PlanItineraryTabPagesState();
}

class _PlanItineraryTabPagesState extends State<PlanItineraryTabList>
    with TickerProviderStateMixin {
  static const _costHeight = 30.0;
  static const _summaryHeight = 80.0;
  static const _detailHeight = 200.0;
  static const _paddingHeight = 10.0;

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
    final theme = context.read<ThemeCubit>().state.bottomBarTheme;
    return Container(color: Colors.red,height: 200,);
    return Theme(
      data: theme,
      child: Container(
        decoration: BoxDecoration(
          color: theme.backgroundColor,
        ),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: height,
                    child: TabBarView(
                      controller: widget.tabController,
                      children: widget.itineraries.map<Widget>((
                        PlanItinerary itinerary,
                      ) {
                        return Container();
                        // return _isExpanded
                        //     ? ItineraryDetailsExpanded(
                        //         animationDetailHeight: _animationDetailHeight,
                        //         itinerary: itinerary)
                        //     : ItineraryDetailsCollapsed(
                        //         setIsExpanded: _setIsExpanded,
                        //         itinerary: itinerary,
                        //         ad: widget.ad,
                        //         animationCostHeight: _animationCostHeight,
                        //         animationSummaryHeight:
                        //             _animationSummaryHeight);
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: TabPageSelector(
                      selectedColor: theme.primaryIconTheme.color,
                      controller: widget.tabController,
                    ),
                  )
                ],
              ),
              Positioned(
                top: 4.0,
                right: 0.0,
                child: IconButton(
                  icon: _isExpanded
                      ? const Icon(Icons.keyboard_arrow_down)
                      : const Icon(Icons.keyboard_arrow_up),
                  color: theme.primaryIconTheme.color,
                  onPressed: () => _setIsExpanded(!_isExpanded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setIsExpanded(bool isExpanded) {
    setState(() {
      _isExpanded = isExpanded;
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
