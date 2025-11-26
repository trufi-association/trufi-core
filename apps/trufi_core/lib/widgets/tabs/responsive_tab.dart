import 'package:flutter/material.dart';
import 'package:trufi_core/widgets/tabs/tab_item_button.dart';

/// A responsive tab widget that allows switching between different views.
/// ## Usage
/// Create an instance with a list of [tabs] and corresponding [children] widgets to display.
class ResponsiveTab extends StatefulWidget {
  const ResponsiveTab({super.key, required this.tabs, required this.children});

  final List<TabItem> tabs;
  final List<Widget> children;

  @override
  State<ResponsiveTab> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ResponsiveTab> {
  int index = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...widget.tabs.map(
                (e) => TabItemButton(
                  label: e.text,
                  isSelected: index == e.index,
                  onPressed: () {
                    setState(() {
                      index = e.index;
                    });
                  },
                  leadingIcon: e.icon,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0.8, thickness: 0.8),
        SizedBox(height: 5),
        widget.children[index],
      ],
    );
  }
}

/// Represents an item in a tab bar.
/// It holds the index, text label, optional icon, and a flag to prevent exiting the tab.
class TabItem {
  TabItem({
    required this.index,
    required this.text,
    this.icon,
    this.preventExitTab = false,
  });

  final int index;
  final String text;
  final IconData? icon;
  final bool preventExitTab;
}
