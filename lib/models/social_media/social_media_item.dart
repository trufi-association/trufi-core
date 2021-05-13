import 'package:flutter/material.dart';

abstract class SocialMediaItem {
  String getTitle(BuildContext context);
  String get url;
  WidgetBuilder get buildIcon;
}
