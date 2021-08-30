import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final bool isDark;
  final double borderRadius;
  final double height;
  final double width;
  final Color color;
  const CustomTextButton({
    Key key,
    @required this.text,
    @required this.onPressed,
    this.isDark = true,
    this.borderRadius = 18.0,
    this.height,
    this.width,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      width: width,
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(
                color: isDark ? Colors.transparent : Colors.black,
              ),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            color ?? (isDark ? theme.primaryColor : Colors.white),
          ),
          padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 10)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white : theme.primaryColor,
          ),
        ),
      ),
    );
  }
}
