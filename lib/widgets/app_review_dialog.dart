import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_review/app_review.dart';

import 'package:trufi_app/trufi_localizations.dart';

void showAppReviewDialog(BuildContext context) async {
  final localizations = TrufiLocalizations.of(context);
  if (Platform.isIOS) {
    // Show native app review dialog for iOS users
    await AppReview.requestReview;
  } else {
    // Show a custom dialog for Android users
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.appReviewDialogTitle()),
          content: Text(localizations.appReviewDialogContent()),
          actions: <Widget>[
            FlatButton(
              child: Text(localizations.appReviewDialogButtonDecline()),
              onPressed: (){
                Navigator.of(context).pop();
              }
            ),
            FlatButton(
              child: Text(localizations.appReviewDialogButtonAccept()),
              onPressed: (){
                Navigator.of(context).pop();
                AppReview.writeReview;
              }
            ),
          ],
        );
      },
    );
  }
}