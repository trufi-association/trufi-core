import 'contact_info.dart';

class BookingInfoEntity {
  final String? message;
  final String? dropOffMessage;
  final ContactInfoEntity? contactInfo;

  const BookingInfoEntity({this.message, this.dropOffMessage, this.contactInfo});

  static const String _message = 'message';
  static const String _dropOffMessage = 'dropOffMessage';
  static const String _contactInfo = 'contactInfo';

  factory BookingInfoEntity.fromJson(Map<String, dynamic> map) => BookingInfoEntity(
    message: map[_message],
    dropOffMessage: map[_dropOffMessage],
    contactInfo:
        map[_contactInfo] != null
            ? ContactInfoEntity.fromJson(map[_contactInfo] as Map<String, dynamic>)
            : null,
  );

  Map<String, dynamic> toJson() => {
    _message: message,
    _dropOffMessage: dropOffMessage,
    _contactInfo: contactInfo?.toJson(),
  };
}
