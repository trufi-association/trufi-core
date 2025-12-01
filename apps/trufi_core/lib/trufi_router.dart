import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';


class TrufiRouter {
  final RouteInformationParser<Object> routeInformationParser;
  final RouterDelegate<Object> routerDelegate;

  TrufiRouter({
    this.routeInformationParser = const RoutemasterParser(),
    required this.routerDelegate,
  });
}
