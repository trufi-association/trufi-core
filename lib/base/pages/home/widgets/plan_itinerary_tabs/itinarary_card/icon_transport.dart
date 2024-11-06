import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/base/utils/text/outlined_text.dart';

class IconTransport extends StatelessWidget {
  final Color color;
  final Color bacgroundColor;
  final String text;
  final Widget icon;
  final Widget? secondaryIcon;
  final bool isEnd;

  const IconTransport({
    super.key,
    required this.color,
    required this.bacgroundColor,
    required this.text,
    required this.icon,
    this.secondaryIcon,
    required this.isEnd,
  });

  @override
  Widget build(BuildContext context) {
    final contrastColor = getContrastColor(bacgroundColor);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: bacgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 22,
            width: 22,
            child: icon,
          ),
          if (secondaryIcon != null)
            SizedBox(
              height: 22,
              width: 22,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: secondaryIcon,
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 2),
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: contrastColor,
                ),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
              ),
            ),
          ),
          if (!isEnd)
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                Icons.arrow_forward_ios,
                color: contrastColor,
                size: 15,
              ),
            ),
        ],
      ),
    );
  }
}
