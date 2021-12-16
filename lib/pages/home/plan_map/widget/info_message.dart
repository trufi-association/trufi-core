import 'package:flutter/material.dart';

class InfoMessage extends StatelessWidget {
  final String message;
  final Widget? widget;
  final EdgeInsetsGeometry? margin;
  final Function? closeInfo;
  final bool isErrorMessage;

  const InfoMessage({
    Key? key,
    required this.message,
    this.widget,
    this.margin,
    this.closeInfo,
    this.isErrorMessage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      // TODO change width for a expanded message horizontal
      width: 250,
      child: Stack(
        children: [
          Container(
            margin: closeInfo != null
                ? const EdgeInsets.symmetric(
                    vertical: 7,
                    horizontal: 5,
                  )
                : margin,
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
            decoration: BoxDecoration(
              color:
                  isErrorMessage ? Colors.grey[300] : const Color(0xffe5f2fa),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isErrorMessage ? Icons.warning : Icons.info,
                      color: isErrorMessage
                          ? const Color(0xffdc2251)
                          : theme.primaryColor,
                      size: 17,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        message,
                        style: theme.textTheme.bodyText1!.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                if (widget != null) widget!
              ],
            ),
          ),
          if (closeInfo != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(1.5),
                child: GestureDetector(
                  onTap: () => closeInfo!(),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
