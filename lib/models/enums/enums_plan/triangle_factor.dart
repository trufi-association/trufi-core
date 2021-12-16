part of 'enums_plan.dart';

enum TriangleFactor {
  lessPublicTransport,
  normal,
  morePublicTransport,
  unknown,
}

TriangleFactor getTriangleFactorByString(String? triangleFactor) {
  return TriangleFactorExtension.names.keys.firstWhere(
    (key) => key.name == triangleFactor,
    orElse: () => TriangleFactor.unknown,
  );
}

final listTriangleFactor = [
  TriangleFactor.lessPublicTransport,
  TriangleFactor.normal,
  TriangleFactor.morePublicTransport,
];

extension TriangleFactorExtension on TriangleFactor {
  static const names = <TriangleFactor, String>{
    TriangleFactor.lessPublicTransport: 'LESS_PUBLIC_TRANSPORT',
    TriangleFactor.normal: 'NORMAL',
    TriangleFactor.morePublicTransport: 'MORE_PUBLIC_TRANSPORT',
    TriangleFactor.unknown: 'UNKNOWN',
  };
  static const values = <TriangleFactor, Map<String, double>?>{
    TriangleFactor.lessPublicTransport: {
      'safetyFactor': 0.5555555555555556,
      'slopeFactor': 0.1873142020882622,
      'timeFactor': 0.2571302423561822
    },
    TriangleFactor.normal: null,
    TriangleFactor.morePublicTransport: {
      'safetyFactor': 0.2888808197601882,
      'slopeFactor': 0.1555636246842562,
      'timeFactor': 0.5555555555555556
    },
    TriangleFactor.unknown: null,
  };

  String get name => names[this] ?? 'UNKNOWN';

  Map<String, double>? get value => values[this];

  String translateValue(TrufiLocalization localization) {
    switch (this) {
      case TriangleFactor.lessPublicTransport:
        return "Mehr Rad";
        break;
      case TriangleFactor.normal:
        return "Beides";
        break;
      case TriangleFactor.morePublicTransport:
        return "Mehr ÖPNV";
        break;
      default:
        return localization.commonError;
    }
  }
}
