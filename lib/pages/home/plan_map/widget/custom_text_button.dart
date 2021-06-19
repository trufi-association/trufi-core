import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final double height;
  final bool isDark;
  const CustomTextButton({
    Key key,
    @required this.text,
    @required this.onPressed,
    this.isDark = true,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(
                color: isDark ? Colors.transparent : Colors.black,
              ),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            isDark ? theme.primaryColor : Colors.white,
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
