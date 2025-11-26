import 'package:trufi_core/models/enums/vertex_type.dart';

enum VertexType { normal, transit, bikepark, bikeshare, parkandride }

VertexType getVertexTypeByString(String vertexType) {
  return VertexTypeExtension.names.keys.firstWhere(
    (key) => key.name == vertexType,
    orElse: () => VertexType.normal,
  );
}

extension VertexTypeExtension on VertexType {
  static const names = <VertexType, String>{
    VertexType.normal: 'NORMAL',
    VertexType.transit: 'TRANSIT',
    VertexType.bikepark: 'BIKEPARK',
    VertexType.bikeshare: 'BIKESHARE',
    VertexType.parkandride: 'PARKANDRIDE',
  };
  String get name => names[this]!;

  VertexTypeTrufi toVertexType() {
    switch (this) {
      case VertexType.normal:
        return VertexTypeTrufi.normal;
      case VertexType.transit:
        return VertexTypeTrufi.transit;
      case VertexType.bikepark:
        return VertexTypeTrufi.bikepark;
      case VertexType.bikeshare:
        return VertexTypeTrufi.bikeshare;
      case VertexType.parkandride:
        return VertexTypeTrufi.parkandride;
    }
  }
}
