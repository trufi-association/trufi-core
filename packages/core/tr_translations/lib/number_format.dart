import 'package:intl/intl.dart';

String formatNumber(num value, String format, {String localName = 'en'}) {
  final numberFormat = NumberFormat(format, localName);
  return numberFormat.format(value);
}
