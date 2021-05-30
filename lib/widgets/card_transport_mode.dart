import 'package:flutter/material.dart';

class CardTransportMode extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Function onTap;

  const CardTransportMode({
    Key key,
    @required this.icon,
    @required this.title,
    @required this.subtitle,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 0.2,
              blurRadius: 0.8,
              offset: const Offset(0, 0.5),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              height: 27,
              width: 27,
              child: icon,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyText1
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyText1
                      .copyWith(fontWeight: FontWeight.w300),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
