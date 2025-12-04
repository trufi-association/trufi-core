// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'about_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AboutLocalizationsDe extends AboutLocalizations {
  AboutLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get aboutCollapseContent =>
      'Die Trufi Association ist eine internationale NGO, die einen einfacheren Zugang zu öffentlichen Verkehrsmitteln fördert. Unsere Apps helfen jedem, den besten Weg von Punkt A nach Punkt B in seiner Stadt zu finden.\n\nIn vielen Städten gibt es keine offiziellen Karten, Routen, Apps oder Fahrpläne. Daher sammeln wir die verfügbaren Informationen und erstellen Routen manchmal sogar von Grund auf neu, indem wir mit Einheimischen zusammenarbeiten, die die Stadt kennen. Ein benutzerfreundliches Verkehrssystem trägt zu größerer Nachhaltigkeit, sauberer Luft und einer besseren Lebensqualität bei.';

  @override
  String get aboutCollapseContentFoot =>
      'Wir brauchen Mapper, Entwickler, Planer, Tester und viele andere helfende Hände.';

  @override
  String get aboutCollapseTitle => 'Mehr über die Trufi Association';

  @override
  String aboutContent(String appName, String city) {
    return 'Du musst irgendwo hin und weißt nicht, welchen Trufi oder Bus Du nehmen sollst?\nDie $appName macht es einfach!\n\nDie Trufi Association ist ein Team aus Bolivien und aus aller Welt. Wir lieben La Llajta und die öffentlichen Verkehrsmittel, deshalb haben wir diese Anwendung entwickelt, um den ÖPNV zugänglicher zu machen. Unser Ziel ist es, Dir ein praktisches Werkzeug an die Hand zu geben, mit dem Du Dich sicher bewegen kannst.\n\nWir sind bestrebt, die $appName ständig zu verbessern, um Dir immer richtige und nützliche Informationen bereitstellen zu können. Wir wissen, dass das Verkehrssystem in $city aus verschiedenen Gründen ständig im Wandel ist und es so möglich ist, dass einige Routen nicht ganz aktuell sind.\n\nUm die $appName zu einem effektiven Werkzeug zu machen, sind wir auf Deine Mitarbeit angewiesen. Wenn Dir Änderungen an einigen Routen oder Haltestellen bekannt sind, bitten wir Dich, diese Informationen mit uns zu teilen. Dein Beitrag trägt nicht nur dazu bei, die App auf dem neuesten Stand zu halten, sondern kommt auch anderen Nutzern zugute, die sich auf die $appName verlassen.\n\nVielen Dank, dass Du die $appName dazu nutzt, um Dich in $city fortzubewegen. Wir hoffen, dass Du Deine Zeit mit uns genießt!';
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
  String get trufiWebsite => 'Website der Trufi Association';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get volunteerTrufi => 'Werde ehrenamtlicher Helfer für Trufi';
}
