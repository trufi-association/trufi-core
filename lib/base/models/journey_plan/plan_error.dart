part of 'plan.dart';

class PlanError {
  PlanError(this.id, this.message);

  static const String _id = "id";
  static const String _message = "msg";

  final int id;
  final String message;

  factory PlanError.fromJson(Map<String, dynamic> json) {
    return PlanError(json[_id] as int, json[_message] as String);
  }

  factory PlanError.fromError(String error) {
    return PlanError(-1, error);
  }

  Map<String, dynamic> toJson() {
    return {
      _id: id,
      _message: message,
    };
  }
}