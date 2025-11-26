import 'package:trufi_core/models/pickup_booking_info.dart';

import 'contact_info.dart';

class PickupBookingInfo {
  final String? message;
  final ContactInfo? contactInfo;

  const PickupBookingInfo({this.message, this.contactInfo});

  factory PickupBookingInfo.fromMap(Map<String, dynamic> map) =>
      PickupBookingInfo(
        message: map['message'] as String?,
        contactInfo: map['contactInfo'] != null
            ? ContactInfo.fromMap(map['contactInfo'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toMap() => {
    'message': message,
    'contactInfo': contactInfo?.toMap(),
  };

  PickupBookingInfoEntity toPickupBookingInfoEntity() {
    return PickupBookingInfoEntity(
      message: message,
      contactInfo: contactInfo?.toContactInfoEntity(),
    );
  }
}
