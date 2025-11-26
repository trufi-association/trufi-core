enum VertexTypeTrufi { normal, transit, bikepark, bikeshare, parkandride }

VertexTypeTrufi getVertexTypeByString(String vertexType) {
  return VertexTypeExtension.names.keys.firstWhere(
    (key) => key.name == vertexType,
    orElse: () => VertexTypeTrufi.normal,
  );
}

extension VertexTypeExtension on VertexTypeTrufi {
  static const names = <VertexTypeTrufi, String>{
    VertexTypeTrufi.normal: 'NORMAL',
    VertexTypeTrufi.transit: 'TRANSIT',
    VertexTypeTrufi.bikepark: 'BIKEPARK',
    VertexTypeTrufi.bikeshare: 'BIKESHARE',
    VertexTypeTrufi.parkandride: 'PARKANDRIDE'
  };
  String get name => names[this]!;
}
