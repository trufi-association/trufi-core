import 'dart:io';

import 'package:app_review/app_review.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/preferences_bloc.dart';
import '../custom_icons.dart';
import '../pages/about.dart';
import '../pages/feedback.dart';
import '../pages/home.dart';
import '../pages/saved_places.dart';
import '../pages/team.dart';
import '../trufi_configuration.dart';

class TrufiDrawer extends StatefulWidget {
  TrufiDrawer(this.currentRoute);

  final String currentRoute;

  @override
  TrufiDrawerState createState() => TrufiDrawerState();
}

class TrufiDrawerState extends State<TrufiDrawer> {
  AssetImage bgImage;
  final GlobalKey appShareButtonKey =
      GlobalKey(debugLabel: "appShareButtonKey");

  @override
  void initState() {
    super.initState();

    // TODO: Should have some kind of fallback image
    bgImage = AssetImage(TrufiConfiguration().image.drawerBackground);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(bgImage, context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    final cfg = TrufiConfiguration();
    final currentLocale = Localizations.localeOf(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor,
              image: DecorationImage(
                image: bgImage,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    const Color.fromRGBO(0, 0, 0, 0.5), BlendMode.multiply),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  cfg.customTranslations.get(
                    cfg.customTranslations.title,
                    currentLocale,
                    localization.title,
                  ),
                  style: theme.primaryTextTheme.title,
                ),
                Container(
                  padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Text(
                    cfg.customTranslations.get(
                      cfg.customTranslations.tagline,
                      currentLocale,
                      localization.tagline(cfg.generalConfiguration.appCity),
                    ),
                    style: theme.primaryTextTheme.subhead,
                  ),
                ),
              ],
            ),
          ),
          _buildListItem(
            Icons.linear_scale,
            localization.menuConnections,
            HomePage.route,
          ),
          _buildListItem(
            Icons.room,
            localization.menuYourPlaces,
            SavedPlacesPage.route,
          ),
          _buildListItem(
            Icons.feedback,
            localization.menuFeedback,
            FeedbackPage.route,
          ),
          _buildListItem(
            Icons.people,
            localization.menuTeam,
            TeamPage.route,
          ),
          _buildListItem(
            Icons.info,
            localization.menuAbout,
            AboutPage.route,
          ),
          Divider(),
          // FIXME: For now we do not provide this option
          //_buildOfflineToggle(context),
          _buildLanguageDropdownButton(context),
          _buildAppReviewButton(context),
          _buildAppShareButton(context, cfg.url.share),
          if (!Platform.isIOS && cfg.url.donate != "")
            _buildWebLinkItem(
              Icons.monetization_on,
              localization.donate,
              cfg.url.donate,
            ),
          Divider(),
          if (cfg.url.website != "")
            _buildWebLinkItem(
              CustomIcons.trufi,
              localization.readOurBlog,
              cfg.url.website,
            ),
          if (cfg.url.facebook != "")
            _buildWebLinkItem(
              CustomIcons.facebook,
              localization.followOnFacebook,
              cfg.url.facebook,
            ),
          if (cfg.url.twitter != "")
            _buildWebLinkItem(
              CustomIcons.twitter,
              localization.followOnTwitter,
              cfg.url.twitter,
            ),
          if (cfg.url.instagram != "")
            _buildWebLinkItem(
              CustomIcons.instagram,
              localization.followOnInstagram,
              cfg.url.instagram,
            ),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData iconData, String title, String route) {
    bool isSelected = widget.currentRoute == route;
    return Container(
      color: isSelected ? Colors.grey[300] : null,
      child: ListTile(
        leading: Icon(iconData, color: isSelected ? Colors.black : Colors.grey),
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).textTheme.body2.color),
        ),
        selected: isSelected,
        onTap: () {
          Navigator.popUntil(context, ModalRoute.withName(HomePage.route));
          if (route != HomePage.route) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }

  Widget _buildLanguageDropdownButton(BuildContext context) {
    final values = TrufiConfiguration()
        .languages
        .map((lang) =>
            LanguageDropdownValue(lang.languageCode, lang.displayName))
        .toList();
    final preferencesBloc = PreferencesBloc.of(context);
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    return ListTile(
      leading: Icon(Icons.language),
      title: DropdownButton<LanguageDropdownValue>(
        style: theme.textTheme.body2,
        value: values.firstWhere((value) => value.languageCode == languageCode),
        onChanged: (LanguageDropdownValue value) {
          preferencesBloc.inChangeLanguageCode.add(value.languageCode);
        },
        items: values.map((LanguageDropdownValue value) {
          return DropdownMenuItem<LanguageDropdownValue>(
            value: value,
            child: Text(
              value.languageString,
              style: theme.textTheme.body2,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOfflineToggle(BuildContext context) {
    final preferencesBloc = PreferencesBloc.of(context);
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return StreamBuilder(
      stream: preferencesBloc.outChangeOnline,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        bool isOnline = snapshot.data == true;
        return SwitchListTile(
          title: Text(localization.menuOnline),
          value: isOnline,
          onChanged: preferencesBloc.inChangeOnline.add,
          activeColor: theme.primaryColor,
          secondary: Icon(isOnline ? Icons.cloud : Icons.cloud_off),
        );
      },
    );
  }

  Widget _buildAppReviewButton(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return Container(
      child: ListTile(
        leading: Icon(Icons.star, color: Colors.grey),
        title: Text(
          localization.menuAppReview,
          style: TextStyle(color: Theme.of(context).textTheme.body2.color),
        ),
        onTap: () async {
          await AppReview.writeReview;
        },
      ),
    );
  }

  Rect getAppShareButtonOrigin() {
    final RenderBox box =
        appShareButtonKey.currentContext.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Widget _buildAppShareButton(BuildContext context, String url) {
    final cfg = TrufiConfiguration();
    final currentLocale = Localizations.localeOf(context);
    final localization = TrufiLocalization.of(context);
    return Container(
      key: appShareButtonKey,
      child: ListTile(
        leading: Icon(Icons.share, color: Colors.grey),
        title: Text(
          localization.menuShareApp,
          style: TextStyle(color: Theme.of(context).textTheme.body2.color),
        ),
        onTap: () {
          Share.share(
            localization.shareAppText(
              url,
              cfg.customTranslations.get(
                cfg.customTranslations.title,
                currentLocale,
                localization.title,
              ),
              cfg.generalConfiguration.appCity,
            ),
            sharePositionOrigin: getAppShareButtonOrigin(),
          );
        },
      ),
    );
  }

  Widget _buildWebLinkItem(IconData iconData, String title, String url) {
    return Container(
      child: ListTile(
        leading: Icon(iconData, color: Colors.grey),
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).textTheme.body2.color),
        ),
        onTap: () => launch(url),
      ),
    );
  }
}

class TrufiDrawerRoute<T> extends MaterialPageRoute<T> {
  TrufiDrawerRoute({
    WidgetBuilder builder,
    RouteSettings settings,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class LanguageDropdownValue {
  LanguageDropdownValue(this.languageCode, this.languageString);

  final String languageCode;
  final String languageString;
}
