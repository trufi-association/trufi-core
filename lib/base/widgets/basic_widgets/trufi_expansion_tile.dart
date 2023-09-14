import 'package:flutter/material.dart';
import 'package:trufi_core/base/widgets/material_widgets/custom_material_widgets.dart';

enum ExpansionTileTitleType {
  primary,
  secondary,
  tertiary,
}

extension ExpansionTileTitleTypeExtension on ExpansionTileTitleType {
  static final textStyles = <ExpansionTileTitleType, TextStyle>{
    ExpansionTileTitleType.primary: const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    ExpansionTileTitleType.secondary: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    ExpansionTileTitleType.tertiary: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  };
  static final backgroundColor = <ExpansionTileTitleType, Color>{
    ExpansionTileTitleType.primary: const Color(0xff2A3034),
    ExpansionTileTitleType.secondary: const Color(0xff374043),
    ExpansionTileTitleType.tertiary: const Color(0xff4C5156),
  };

  TextStyle get getStyle =>
      textStyles[this] ??
      const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
  Color get getBackgroundColor =>
      backgroundColor[this] ?? const Color(0xff2A3034);
}

class TrufiExpansionTile extends StatelessWidget {
  static const styleTextContent = TextStyle(
    height: 1.3,
    fontSize: 15,
  );
  final String title;
  final Widget? body;
  final EdgeInsets padding;
  final ExpansionTileTitleType typeTitle;
  final TextAlign? textAlign;

  const TrufiExpansionTile({
    super.key,
    required this.title,
    required this.body,
    this.padding = const EdgeInsets.all(15),
    this.typeTitle = ExpansionTileTitleType.primary,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff777777) : Colors.grey.shade200,
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 0),
          ),
        ],
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomExpansionTile(
          maintainState: true,
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          titleColor: typeTitle.getBackgroundColor,
          trailing: body != null ? null : Container(width: 1),
          title: Text(
            title,
            style: typeTitle.getStyle,
            textAlign: textAlign,
          ),
          children: [
            if (body != null)
              Container(
                padding: padding,
                child: body,
              ),
          ],
        ),
      ),
    );
  }
}
