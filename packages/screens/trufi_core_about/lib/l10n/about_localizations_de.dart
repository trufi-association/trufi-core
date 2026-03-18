// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'about_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AboutLocalizationsDe extends AboutLocalizations {
  AboutLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get aboutCollapseContent =>
      'Trufi Association ist eine internationale NGO, die einen einfacheren Zugang zum öffentlichen Nahverkehr fördert. Unsere Apps helfen allen, den besten Weg von A nach B in ihren Städten zu finden.\n\nIn vielen Städten gibt es keine offiziellen Karten, Routen, Apps oder Fahrpläne. Wir stellen die verfügbaren Informationen zusammen und erstellen manchmal sogar Routen von Grund auf, in Zusammenarbeit mit Einheimischen, die die Stadt kennen. Ein benutzerfreundliches Verkehrssystem trägt zu mehr Nachhaltigkeit, sauberer Luft und einer besseren Lebensqualität bei.';

  @override
  String get aboutCollapseContentFoot =>
      'Wir brauchen Mapper, Entwickler, Planer, Tester und viele weitere helfende Hände.';

  @override
  String get aboutCollapseTitle => 'Mehr über die Trufi Association';

  @override
  String aboutContent(String appName, String city) {
    return 'Du musst irgendwo hin und weißt nicht, welchen Bus oder welche Route Du nehmen sollst?\n$appName macht es einfach!\n\nDie Trufi Association ist ein internationales Team von Freiwilligen. Wir lieben die öffentlichen Verkehrsmittel, deshalb haben wir diese Anwendung entwickelt, um den ÖPNV zugänglicher zu machen. Unser Ziel ist es, Dir ein praktisches Werkzeug an die Hand zu geben, mit dem Du Dich sicher bewegen kannst.\n\nWir sind bestrebt, die $appName ständig zu verbessern, um Dir immer richtige und nützliche Informationen bereitstellen zu können. Wir wissen, dass das Verkehrssystem in $city aus verschiedenen Gründen ständig im Wandel ist und es so möglich ist, dass einige Routen nicht ganz aktuell sind.\n\nUm die $appName zu einem effektiven Werkzeug zu machen, sind wir auf Deine Mitarbeit angewiesen. Wenn Dir Änderungen an einigen Routen oder Haltestellen bekannt sind, bitten wir Dich, diese Informationen mit uns zu teilen. Dein Beitrag trägt nicht nur dazu bei, die App auf dem neuesten Stand zu halten, sondern kommt auch anderen Nutzern zugute, die sich auf die $appName verlassen.\n\nVielen Dank, dass Du die $appName dazu nutzt, um Dich in $city fortzubewegen. Wir hoffen, dass Du Deine Zeit mit uns genießt!';
  }

  @override
  String get aboutLicenses => 'Lizenzen';

  @override
  String get aboutOpenSource =>
      'Diese App ist als Open Source auf GitHub veröffentlicht. Wir freuen uns, wenn Du zum Code beiträgst oder eine App für Deine eigene Stadt entwickelst.';

  @override
  String get menuAbout => 'Über Uns';

  @override
  String tagline(String city) {
    return 'Öffentliche Verkehrsmittel in $city';
  }

  @override
  String get trufiWebsite => 'Trufi Association Website';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get volunteerTrufi => 'Freiwilligenarbeit für Trufi';
}
