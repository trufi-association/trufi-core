import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/services/exception/fetch_online_exception.dart';
import 'package:trufi_core/base/pages/home/services/request_plan_service.dart';
import 'package:trufi_core/base/utils/packge_info_platform.dart';
import 'package:trufi_core/base/utils/trufi_app_id.dart';

class RealtimeRequestService {
  static const String searchPath = '/geocode';
  static const String planPath = '/plan';
  final String otpEndpoint;

  RealtimeRequestService({
    required this.otpEndpoint,
  });

}
