import 'package:flutter/material.dart';

import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class AboutPage extends StatelessWidget {
  static const String route = "/About";
  final Widget Function(BuildContext) drawerBuilder;

  const AboutPage({
    Key? key,
    required this.drawerBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    final theme = Theme.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == "en";
    final textTheme =
        theme.textTheme.bodyText2?.copyWith(fontSize: 16, height: 1.5);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(localization.menuAbout),
          ],
        ),
      ),
      drawer: drawerBuilder(context),
      body: SafeArea(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          children: [
            const SizedBox(height: 40),
            Text(
              isEnglish ? "About Us" : "Über Uns",
              style: theme.textTheme.bodyText2?.copyWith(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: ExpansionTile(
                  title: Text(
                    isEnglish
                        ? "We are the coolest group ever! Any other questions?"
                        : "Wir sind eine echt coole Truppe. Noch Fragen?",
                    style: textTheme,
                  ),
                  children: [
                    RichText(
                      text: TextSpan(style: textTheme, children: <TextSpan>[
                        TextSpan(
                          text: isEnglish
                              ? "Dear Bike and Public Transport User!\n\n"
                              : "Lieber Fahrrad- und ÖPNV-Nutzer!\n\n",
                        ),
                        TextSpan(
                          text: isEnglish
                              ? "Not Without My Bike "
                              : "Nicht ohne mein Rad ",
                          style:
                              textTheme?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: isEnglish
                              ? "unites bicycle and public transport "
                                  "journeys in Hamburg, making life easier for people "
                                  "who use bikes as their main means of transport. "
                                  "Defy long trips and rainy days by using public "
                                  "transport without abandoning your bike! ITS World Congress "
                                  "and the Hamburg Transport Association (hvv GmbH) chose "
                                  "Trufi Association to create a first-of-its-kind bike app, "
                                  "and voilà, here it is: "
                              : "vereint Fahrrad und ÖPNV in "
                                  "Hamburg und macht das Leben für Menschen, "
                                  "die das Fahrrad als Hauptverkehrsmittel nutzen, "
                                  "einfacher. In Zukunft kannst du langen Wegen oder "
                                  "Regentagen mit der Nutzung der ÖPNV die Stirn "
                                  "bieten ohne auf dein Rad zu verzichten. Deshalb "
                                  "haben wir von Trufi Association im Auftrag der ITS "
                                  "und der hvv GmbH Nägel mit Köpfen gemacht und voilà: "
                                  "Hier ist ",
                        ),
                        TextSpan(
                          text: isEnglish
                              ? "Not Without My Bike Hamburg!"
                              : "Nicht ohne mein Rad Hamburg!",
                          style:
                              textTheme?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: isEnglish
                              ? "\n\nTrufi Association is an international NGO that promotes "
                                  "easier access to public transport. Official maps, apps, "
                                  "and schedules don’t provide all the routes, or they "
                                  "simply don’t exist in many cities. We fill in the "
                                  "gaps – and sometimes even map the routes from scratch. "
                                  "Our apps help everyone find the best way to get from "
                                  "Point A to Point B within their cities. Well-designed "
                                  "mobility contributes to greater sustainability, cleaner "
                                  "air and better quality of life.\n"
                              : "\n\nTrufi Association ist eine internationale NGO, "
                                  "die sich für einen leichteren Zugang zu öffentlichen "
                                  "Verkehrsmitteln einsetzt. Offizielle Karten, Apps "
                                  "und Fahrpläne enthalten oft nicht alle Routen. In "
                                  "vielen Städten dieser Welt gibt es sogar gar keine "
                                  "Fahrpläne. Wir füllen Lücken oder zeichnen Routen "
                                  "von Grund auf neu auf. Unsere Apps helfen jedem, den "
                                  "besten Weg zu finden, um in seiner Stadt von A nach B "
                                  "zu kommen. Gut durchdachte Mobilität trägt zu mehr "
                                  "Nachhaltigkeit, sauberer Luft und mehr Lebensqualität bei.\n",
                        ),
                      ]),
                    ),
                  ],
                  backgroundColor: theme.colorScheme.surface,
                  collapsedBackgroundColor: theme.colorScheme.surface,
                  collapsedIconColor: theme.iconTheme.color,
                  iconColor: theme.iconTheme.color,
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                  childrenPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                ),
              ),
            ),
            const SizedBox(height: 80),
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/trufi-logo.png',
                      package: 'trufi_core',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
