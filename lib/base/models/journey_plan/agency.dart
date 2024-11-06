part of 'plan.dart';

class Agency extends Equatable {
  static const _name = 'name';

  final String name;

  const Agency({
    this.name = 'Not name',
  });

  Map<String, dynamic> toJson() {
    return {
      _name: name,
    };
  }

  factory Agency.fromJson(Map<String, dynamic> map) {
    return Agency(
      name: map[_name],
    );
  }

  @override
  List<Object?> get props => [name];
}
