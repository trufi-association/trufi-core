import 'about_localizations.dart';

/// The translations for German (`de`).
class AboutLocalizationDe extends AboutLocalization {
  AboutLocalizationDe([String locale = 'de']) : super(locale);

  @override
  String get aboutCollapseContent => 'Trufi Association is an international NGO that promotes easier access to public transport. Our apps help everyone find the best way to get from point A to point B within their cities.\n\nIn many cities there are no official maps, routes, apps or timetables. So we compile the available information, and sometimes even map routes from scratch working with local people who know the city.  An easy-to-use transportation system contributes to greater sustainability, cleaner air and a better quality of life.';

  @override
  String get aboutCollapseContentFoot => 'We need mappers, developers, planners, testers, and many other hands.';

  @override
  String get aboutCollapseTitle => 'More About Trufi Association';

  @override
  String aboutContent(Object appName, Object city) {
    return 'Du musst irgendwo hin und weißt nicht, welchen Trufi oder Bus Du nehmen sollst?\nDie $appName macht es einfach!\n\nDie Trufi Association ist ein Team aus Bolivien und aus aller Welt. Wir lieben La Llajta und die öffentlichen Verkehrsmittel, deshalb haben wir diese Anwendung entwickelt, um den ÖPNV zugänglicher zu machen. Unser Ziel ist es, Dir ein praktisches Werkzeug an die Hand zu geben, mit dem Du Dich sicher bewegen kannst.\n\nWir sind bestrebt, die $appName ständig zu verbessern, um Dir immer richtige und nützliche Informationen bereitstellen zu können. Wir wissen, dass das Verkehrssystem in $city aus verschiedenen Gründen ständig im Wandel ist und es so möglich ist, dass einige Routen nicht ganz aktuell sind.\n\nUm die $appName zu einem effektiven Werkzeug zu machen, sind wir auf Deine Mitarbeit angewiesen. Wenn Dir Änderungen an einigen Routen oder Haltestellen bekannt sind, bitten wir Dich, diese Informationen mit uns zu teilen. Dein Beitrag trägt nicht nur dazu bei, die App auf dem neuesten Stand zu halten, sondern kommt auch anderen Nutzern zugute, die sich auf die $appName verlassen.\n\nVielen Dank, dass Du die $appName dazu nutzt, um Dich in $city fortzubewegen. Wir hoffen, dass Du Deine Zeit mit uns genießt!';
  }

  @override
  String get aboutLicenses => 'Lizenzen';

  @override
  String get aboutOpenSource => 'Diese App ist als Open Source auf GitHub veröffentlicht. Wir freuen uns, wenn Du zum Code beiträgst oder eine App für Deine eigene Stadt entwickelst.';

  @override
  String get menuAbout => 'Über Uns';

  @override
  String tagline(Object city) {
    return 'Öffentliche Verkehrsmittel in $city';
  }

  @override
  String get trufiWebsite => 'Trufi Association Website';

  @override
  String version(Object version) {
    return 'Version $version';
  }

  @override
  String get volunteerTrufi => 'Volunteer For Trufi';
}
