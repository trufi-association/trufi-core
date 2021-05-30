import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/pages/home/plan_map/plan.dart';

class ModeTransportScreen extends StatelessWidget {
  final PlanEntity plan;
  final String title;

  const ModeTransportScreen({
    Key key,
    @required this.plan,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          // TODO translate
          children: [Text('$title (${plan.itineraries.length} itineraries)')],
        ),
      ),
      body: SafeArea(
        child: PlanPage(plan, null, null, null),
      ),
    );
  }
}
