class ContactInfoEntity {
  final String? phoneNumber;
  final String? infoUrl;
  final String? bookingUrl;

  const ContactInfoEntity({this.phoneNumber, this.infoUrl, this.bookingUrl});

  static const String _phoneNumber = 'phoneNumber';
  static const String _infoUrl = 'infoUrl';
  static const String _bookingUrl = 'bookingUrl';

  factory ContactInfoEntity.fromJson(Map<String, dynamic> map) => ContactInfoEntity(
    phoneNumber: map[_phoneNumber],
    infoUrl: map[_infoUrl],
    bookingUrl: map[_bookingUrl],
  );

  Map<String, dynamic> toJson() => {
    _phoneNumber: phoneNumber,
    _infoUrl: infoUrl,
    _bookingUrl: bookingUrl,
  };
}
