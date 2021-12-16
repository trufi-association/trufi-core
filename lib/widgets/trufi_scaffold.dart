import 'package:flutter/material.dart';

class TrufiScaffold extends StatelessWidget {
  TrufiScaffold({
    Key? key,
    required this.appBar,
    required this.body,
    required this.drawer,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final Widget appBar;
  final Widget body;
  final Widget drawer;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(.5),
                  blurRadius: 20.0,
                  offset: const Offset(
                    5.0,
                    5.0,
                  ),
                )
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: theme.primaryIconTheme.color,
                        ),
                        onPressed: () {
                          _scaffoldKey.currentState!.openDrawer();
                        },
                      ),
                      Expanded(
                        child: appBar,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: body,
          ),
        ],
      ),
      drawer: drawer,
    );
  }
}
