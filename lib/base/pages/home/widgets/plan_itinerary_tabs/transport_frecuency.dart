import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/transport_opening_hours.dart';

/// Routes whose schedule is not an all-day service window but a few fixed
/// departures (`Mo-Su 17:30`: one bus at 17:30) or a short window
/// (`Mo-Su 04:00-05:45`). Same syntax as [transportOpeningHours]; the app
/// renders single times as departures. Looked up through
/// [transportScheduleOf], after [transportOpeningHours].
const Map<String, String> transportFrecuency = {
  ...jilotepecFrecuency,
};

const jilotepecFrecuency = {
  "19525667": "Mo-Su 17:30",
  "19528584": "Mo-Su 04:00-05:45",
  "19528664": "Mo-Su 05:20-08:00",
  "19531729": "Mo-Su 07:25",
  "19531730": "Mo-Su 10:00",
  "19531743": "Mo-Su 08:25",
  "19531744": "Mo-Su 06:40-07:20",
};
