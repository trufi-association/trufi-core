import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/drawer/menu/social_media_item.dart';
import 'package:trufi_core/base/widgets/drawer/menu/default_item_menu.dart';

void main() {
  const fiveLinks = UrlSocialMedia(
    urlFacebook: 'https://facebook.com/x',
    urlInstagram: 'https://instagram.com/x',
    urlTwitter: 'https://twitter.com/x',
    urlTiktok: 'https://tiktok.com/@x',
    urlYoutube: 'https://youtube.com/x',
  );

  Future<void> pumpMenu(WidgetTester tester, UrlSocialMedia urls) async {
    final item = defaultSocialMedia(urls) as SimpleMenuItem;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: TrufiBaseLocalization.localizationsDelegates,
        supportedLocales: TrufiBaseLocalization.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Builder(builder: (context) => item.name(context)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
      'the social media selector builds with five links in a debug build '
      '(trufi-arequipa#72)', (tester) async {
    await pumpMenu(tester, fiveLinks);

    // Before the fix DropdownButton asserted here: selectedItemBuilder
    // returned 0 widgets for 5 items and the drawer showed an ErrorWidget.
    expect(tester.takeException(), isNull);
    expect(find.byType(ErrorWidget), findsNothing);
    expect(find.text('Social media'), findsOneWidget);

    final dropdown = tester.widget<DropdownButton<SocialMediaItem>>(
      find.byType(DropdownButton<SocialMediaItem>),
    );
    final context = tester.element(find.byType(DropdownButton<SocialMediaItem>));
    expect(dropdown.items, hasLength(5));
    expect(dropdown.selectedItemBuilder!(context), hasLength(5));
  });

  testWidgets('the selector lists exactly the links that are configured',
      (tester) async {
    await pumpMenu(
      tester,
      const UrlSocialMedia(urlFacebook: 'https://facebook.com/x'),
    );
    expect(tester.takeException(), isNull);
    final dropdown = tester.widget<DropdownButton<SocialMediaItem>>(
      find.byType(DropdownButton<SocialMediaItem>),
    );
    final context = tester.element(find.byType(DropdownButton<SocialMediaItem>));
    expect(dropdown.items, hasLength(1));
    expect(dropdown.selectedItemBuilder!(context), hasLength(1));
  });
}
