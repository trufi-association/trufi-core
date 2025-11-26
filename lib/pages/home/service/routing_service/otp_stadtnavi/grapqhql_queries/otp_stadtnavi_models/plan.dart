import 'package:trufi_core/models/plan_entity.dart';

import 'debug_output.dart';
import 'itinerary.dart';
import 'place.dart';

class PlanStadtnavi {
  final double? date;
  final Place? from;
  final Place? to;
  final List<Itinerary>? itineraries;
  final List<String>? messageEnums;
  final List<String>? messageStrings;
  final double? prevDateTime;
  final double? nextDateTime;
  final double? searchWindowUsed;
  final DebugOutput? debugOutput;

  const PlanStadtnavi({
    this.date,
    this.from,
    this.to,
    this.itineraries,
    this.messageEnums,
    this.messageStrings,
    this.prevDateTime,
    this.nextDateTime,
    this.searchWindowUsed,
    this.debugOutput,
  });

  factory PlanStadtnavi.fromMap(Map<String, dynamic> json) => PlanStadtnavi(
        date: double.tryParse(json['date'].toString()),
        from: json['from'] != null
            ? Place.fromMap(json['from'] as Map<String, dynamic>)
            : null,
        to: json['to'] != null
            ? Place.fromMap(json['to'] as Map<String, dynamic>)
            : null,
        itineraries: json['itineraries'] != null
            ? List<Itinerary>.from((json["itineraries"] as List<dynamic>).map(
                (x) => Itinerary.fromMap(x as Map<String, dynamic>),
              ))
            : null,
        messageEnums: json['messageEnums'] != null
            ? (json['messageEnums'] as List<dynamic>).cast<String>()
            : null,
        messageStrings: json['messageStrings'] != null
            ? (json['messageStrings'] as List<dynamic>).cast<String>()
            : null,
        prevDateTime: double.tryParse(json['prevDateTime'].toString()),
        nextDateTime: double.tryParse(json['nextDateTime'].toString()),
        searchWindowUsed: double.tryParse(json['searchWindowUsed'].toString()),
        debugOutput: json['debugOutput'] != null
            ? DebugOutput.fromMap(json['debugOutput'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'date': date,
        'from': from?.toMap(),
        'to': to?.toMap(),
        'itineraries': itineraries != null
            ? List<dynamic>.from(itineraries!.map((x) => x.toMap()))
            : null,
        'messageEnums': messageEnums,
        'messageStrings': messageStrings,
        'prevDateTime': prevDateTime,
        'nextDateTime': nextDateTime,
        'searchWindowUsed': searchWindowUsed,
        'debugOutput': debugOutput?.toMap(),
      };

  PlanStadtnavi copyWith({
    double? date,
    Place? from,
    Place? to,
    List<Itinerary>? itineraries,
    List<String>? messageEnums,
    List<String>? messageStrings,
    double? prevDateTime,
    double? nextDateTime,
    double? searchWindowUsed,
    DebugOutput? debugOutput,
  }) {
    return PlanStadtnavi(
      date: date ?? this.date,
      from: from ?? this.from,
      to: to ?? this.to,
      itineraries: itineraries ?? this.itineraries,
      messageEnums: messageEnums ?? this.messageEnums,
      messageStrings: messageStrings ?? this.messageStrings,
      prevDateTime: prevDateTime ?? this.prevDateTime,
      nextDateTime: nextDateTime ?? this.nextDateTime,
      searchWindowUsed: searchWindowUsed ?? this.searchWindowUsed,
      debugOutput: debugOutput ?? this.debugOutput,
    );
  }

  PlanEntity toPlan() {
    final itinerariesTemp = itineraries
            ?.map(
              (itinerary) => itinerary.toPlanItinerary(),
            )
            .toList() ??
        <PlanItinerary>[];
    // PlanEntity.findMinEmissionsPerPerson(itinerariesTemp);
    return PlanEntity(
      to: to?.toPlanLocation(),
      from: from?.toPlanLocation(),
      itineraries: itinerariesTemp,
    ).copyWith(type: 'plan');
  }
}
