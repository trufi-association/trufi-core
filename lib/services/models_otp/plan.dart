import 'debug_output.dart';
import 'itinerary.dart';
import 'place.dart';

class Plan {
  final double date;
  final Place from;
  final Place to;
  final List<Itinerary> itineraries;
  final List<String> messageEnums;
  final List<String> messageStrings;
  final double prevDateTime;
  final double nextDateTime;
  final double searchWindowUsed;
  final DebugOutput debugOutput;

  const Plan({
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

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        date: double.tryParse(json['date'].toString()) ?? 0,
        from: json['from'] != null
            ? Place.fromJson(json['from'] as Map<String, dynamic>)
            : null,
        to: json['to'] != null
            ? Place.fromJson(json['to'] as Map<String, dynamic>)
            : null,
        itineraries: json['itineraries'] != null
            ? List<Itinerary>.from((json["itineraries"] as List<dynamic>).map(
                (x) => Itinerary.fromJson(x as Map<String, dynamic>),
              ))
            : null,
        messageEnums: json['messageEnums'] != null
            ? (json['messageEnums'] as List<dynamic>).cast<String>()
            : null,
        messageStrings: json['messageStrings'] != null
            ? (json['messageStrings'] as List<dynamic>).cast<String>()
            : null,
        prevDateTime: double.tryParse(json['prevDateTime'].toString()) ?? 0,
        nextDateTime: double.tryParse(json['nextDateTime'].toString()) ?? 0,
        searchWindowUsed:
            double.tryParse(json['searchWindowUsed'].toString()) ?? 0,
        debugOutput: json['debugOutput'] != null
            ? DebugOutput.fromJson(json['debugOutput'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'from': from?.toJson(),
        'to': to?.toJson(),
        'itineraries': List.generate(
            itineraries?.length ?? 0, (index) => itineraries[index].toJson()),
        'messageEnums': messageEnums,
        'messageStrings': messageStrings,
        'prevDateTime': prevDateTime,
        'nextDateTime': nextDateTime,
        'searchWindowUsed': searchWindowUsed,
        'debugOutput': debugOutput?.toJson(),
      };
}
