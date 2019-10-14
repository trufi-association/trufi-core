import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:core/trufi_app.dart';

void main() async {
  await GlobalConfiguration().loadFromAsset("app_config");
  runApp(TrufiApp());
}
