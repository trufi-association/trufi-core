import 'package:flutter/material.dart';

class InfoMessage extends StatelessWidget {
  final String message;
  final Widget widget;
  const InfoMessage({
    Key key,
    @required this.message,
    this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xffe5f2fa),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info,
                color: theme.primaryColor,
                size: 17,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  message,
                  style: theme.textTheme.bodyText1.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
          if (widget != null) widget
        ],
      ),
    );
  }
}
