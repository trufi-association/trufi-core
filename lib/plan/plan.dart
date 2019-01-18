import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trufi_app/composite_subscription.dart';
import 'package:trufi_app/plan/plan_itinerary_summary_tabs.dart';
import 'package:trufi_app/plan/plan_itinerary_tabs.dart';
import 'package:trufi_app/plan/plan_map.dart';
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
  static const selectedTabIndicatorHeight = 20;
  static const instructionHeightMin =
      durationHeight + summaryHeight + selectedTabIndicatorHeight;
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
      end: instructionHeightMax - selectedTabIndicatorHeight,
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
          Color backgroundColor = Theme.of(context).primaryColor;
          return Container(
              height: _animationInstructionHeight.value,
              decoration: BoxDecoration(
                color: backgroundColor,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: backgroundColor, blurRadius: 4.0)
                ],
              ),
              child: PlanItinerarySummaryTabPages(
                _animationDurationHeight.value,
                _animationSummaryHeight.value,
                _tabController,
                _planPageController.plan.itineraries,
                _buildToggleSummaryButton(context),
              ));
        });
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
            ? Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey,
              )
            : Icon(Icons.keyboard_arrow_up, color: Colors.grey),
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
