import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';

class BackgroundScreen extends StatelessWidget {
  const BackgroundScreen({Key key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final config = context.read<ConfigurationCubit>().state;
    return Stack(
      children: [
        Column(
          children: [
            const Spacer(),
            if (isPortrait)
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  config.pageBackgroundAssetPath,
                  fit: BoxFit.fill,
                ),
              )
            else
              Image.asset(
                config.pageBackgroundAssetPath,
                fit: BoxFit.fill,
              ),
          ],
        ),
      ],
    );
  }
}
