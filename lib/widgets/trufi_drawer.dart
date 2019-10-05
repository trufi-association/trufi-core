import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:app_review/app_review.dart';
import 'package:flutter/material.dart';
import 'package:trufi_app/custom_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/pages/team.dart';
import 'package:trufi_app/trufi_localizations.dart';

class TrufiDrawer extends StatefulWidget {
  TrufiDrawer(this.currentRoute);

  final String currentRoute;

  @override
  TrufiDrawerState createState() => TrufiDrawerState();
}

class TrufiDrawerState extends State<TrufiDrawer> {
  AssetImage bgImage;

  @override
  void initState() {
    super.initState();

    bgImage = AssetImage("assets/images/drawer-bg.jpg");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(bgImage, context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    final cfg = GlobalConfiguration();
    final urlDonate = cfg.getString("urlDonate");
    final urlShare = cfg.getString("urlShare");
    final urlWebsite = cfg.getString("urlWebsite");
    final urlFacebook = cfg.getString("urlFacebook");
    final urlTwitter = cfg.getString("urlTwitter");
    final urlInstagram = cfg.getString("urlInstagram");
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
                  const Color.fromRGBO(0, 0, 0, 0.5),
                  BlendMode.multiply
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  localizations.title(),
                  style: theme.primaryTextTheme.title,
                ),
                Container(
                  padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Text(
                    localizations.tagline(),
                    style: theme.primaryTextTheme.subhead,
                  ),
                ),
              ],
            ),
          ),
          _buildListItem(
            Icons.linear_scale,
            localizations.menuConnections(),
            HomePage.route,
          ),
          _buildListItem(
            Icons.feedback,
            localizations.menuFeedback(),
            FeedbackPage.route,
          ),
          _buildListItem(
            Icons.people,
            localizations.menuTeam(),
            TeamPage.route,
          ),
          _buildListItem(
            Icons.info,
            localizations.menuAbout(),
            AboutPage.route,
          ),
          Divider(),
          // FIXME: For now we do not provide this option
          //_buildOfflineToggle(context),
          _buildLanguageDropdownButton(context),
          _buildAppReviewButton(context),
          _buildAppShareButton(context, urlShare),
          if (!Platform.isIOS && urlDonate != "") _buildWebLinkItem(
            Icons.monetization_on,
            localizations.donate(),
            urlDonate,
          ),
          Divider(),
          if (urlWebsite != "") _buildWebLinkItem(
            CustomIcons.trufi,
            localizations.readOurBlog(),
            urlWebsite,
          ),
          if (urlFacebook != "") _buildWebLinkItem(
            CustomIcons.facebook,
            localizations.followOnFacebook(),
            urlFacebook,
          ),
          if (urlTwitter != "") _buildWebLinkItem(
            CustomIcons.twitter,
            localizations.followOnTwitter(),
            urlTwitter,
          ),
          if (urlInstagram != "") _buildWebLinkItem(
            CustomIcons.instagram,
            localizations.followOnInstagram(),
            urlInstagram,
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
    final values = supportedLanguages
      .map((lang) => LanguageDropdownValue(lang["languageCode"], lang["languageString"]))
      .toList();
    final preferencesBloc = PreferencesBloc.of(context);
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    final languageCode = localizations.locale.languageCode;
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
    final localizations = TrufiLocalizations.of(context);
    return StreamBuilder(
      stream: preferencesBloc.outChangeOnline,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        bool isOnline = snapshot.data == true;
        return SwitchListTile(
          title: Text(localizations.menuOnline()),
          value: isOnline,
          onChanged: preferencesBloc.inChangeOnline.add,
          activeColor: theme.primaryColor,
          secondary: Icon(isOnline ? Icons.cloud : Icons.cloud_off),
        );
      },
    );
  }

  Widget _buildAppReviewButton(BuildContext context) {
    final localizations = TrufiLocalizations.of(context);
    return Container(
      child: ListTile(
        leading: Icon(Icons.star, color: Colors.grey),
        title: Text(
          localizations.menuAppReview(),
          style: TextStyle(color: Theme.of(context).textTheme.body2.color),
        ),
        onTap: () {
          AppReview.requestReview.then((value) {});
        },
      ),
    );
  }

  Widget _buildAppShareButton(BuildContext context, String url) {
    final localizations = TrufiLocalizations.of(context);
    return Container(
      child: ListTile(
        leading: Icon(Icons.share, color: Colors.grey),
        title: Text(
          localizations.menuShareApp(),
          style: TextStyle(color: Theme.of(context).textTheme.body2.color),
        ),
        onTap: () {
          Share.share(localizations.shareAppText(url));
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
