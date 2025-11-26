import 'contact_info.dart';

class PickupBookingInfoEntity {
  final String? message;
  final ContactInfoEntity? contactInfo;

  const PickupBookingInfoEntity({this.message, this.contactInfo});

  static const String _message = 'message';
  static const String _contactInfo = 'contactInfo';

  factory PickupBookingInfoEntity.fromJson(Map<String, dynamic> map) =>
      PickupBookingInfoEntity(
        message: map[_message],
        contactInfo:
            map[_contactInfo] != null
                ? ContactInfoEntity.fromJson(
                  map[_contactInfo] as Map<String, dynamic>,
                )
                : null,
      );

  Map<String, dynamic> toJson() => {
    _message: message,
    _contactInfo: contactInfo?.toJson(),
  };
}
