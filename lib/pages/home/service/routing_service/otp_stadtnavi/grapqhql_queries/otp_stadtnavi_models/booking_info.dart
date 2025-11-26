import 'package:trufi_core/models/booking_info.dart';

import 'contact_info.dart';

class BookingInfo {
  final String? message;
  final String? dropOffMessage;
  final ContactInfo? contactInfo;

  const BookingInfo({this.message, this.dropOffMessage, this.contactInfo});

  factory BookingInfo.fromMap(Map<String, dynamic> map) => BookingInfo(
    message: map['message'] as String?,
    dropOffMessage: map['dropOffMessage'] as String?,
    contactInfo: map['contactInfo'] != null
        ? ContactInfo.fromMap(map['contactInfo'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toMap() => {
    'message': message,
    'dropOffMessage': dropOffMessage,
    'contactInfo': contactInfo?.toMap(),
  };

  BookingInfoEntity toBookingInfoEntity() {
    return BookingInfoEntity(
      message: message,
      dropOffMessage: dropOffMessage,
      contactInfo: contactInfo?.toContactInfoEntity(),
    );
  }
}
