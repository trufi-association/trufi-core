class GeometryEntity {
  final int? length;
  final String? points;

  const GeometryEntity({this.length, this.points});

  static const String _length = 'length';
  static const String _points = 'points';

  factory GeometryEntity.fromJson(Map<String, dynamic> json) =>
      GeometryEntity(length: json[_length], points: json[_points]);

  Map<String, dynamic> toJson() => {_length: length, _points: points};
}
