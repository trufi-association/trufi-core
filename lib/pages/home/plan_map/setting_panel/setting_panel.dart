import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/models/enums/plan_enums.dart';
import 'package:trufi_core/widgets/custom_expanded_tile.dart';
import 'package:trufi_core/widgets/custom_switch_tile.dart';

import 'setting_panel_cubit.dart';

class SettingPanel extends StatelessWidget {
  static const String route = "/setting-panel";
  const SettingPanel({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // TODO to add all translates this widget
    // final localization = TrufiLocalization.of(context);

    final settingPanelCubit = context.read<SettingPanelCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(settingPanelCubit.state);
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SettingPanelCubit, SettingPanelState>(
          builder: (blocContext, state) {
            return ListView(
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                CustomExpansionTile(
                  title: "Walking speed",
                  options: const [
                    'Slow',
                    'Calm',
                    'Average',
                    'Prompt',
                    'Fast',
                  ],
                  textSelected: _getTextWalkingSelect(context, state.typeWalkingSpeed),
                  onChanged: (value) {
                    switch (value) {
                      case 'Slow':
                        settingPanelCubit.setWalkingSpeed(WalkingSpeed.slow);
                        break;
                      case 'Calm':
                        settingPanelCubit.setWalkingSpeed(WalkingSpeed.calm);
                        break;
                      case 'Average':
                        settingPanelCubit.setWalkingSpeed(WalkingSpeed.average);
                        break;
                      case 'Prompt':
                        settingPanelCubit.setWalkingSpeed(WalkingSpeed.prompt);
                        break;
                      case 'Fast':
                        settingPanelCubit.setWalkingSpeed(WalkingSpeed.fast);
                        break;
                      default:
                    }
                  },
                ),
                const Divider(thickness: 2),
                CustomSwitchTile(
                  title: 'Avoid walking',
                  value: state.avoidWalking,
                  onChanged: (value) => settingPanelCubit.setAvoidWalking(avoidWalking: value),
                ),
                const Divider(thickness: 10),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Transport modes', style: theme.textTheme.bodyText1),
                ),
                CustomSwitchTile(
                  title: 'Bus',
                  secondary: Icon(TransportMode.bus.icon),
                  value: state.transportModes.contains(TransportMode.bus),
                  onChanged: (_) {
                    settingPanelCubit.setTransportMode(TransportMode.bus);
                  },
                ),
                const Divider(
                  thickness: 2,
                  endIndent: 16,
                ),
                CustomSwitchTile(
                  title: 'Commuter train',
                  secondary: Icon(TransportMode.rail.icon),
                  value: state.transportModes.contains(TransportMode.rail),
                  onChanged: (_) {
                    settingPanelCubit.setTransportMode(TransportMode.rail);
                  },
                ),
                const Divider(
                  thickness: 2,
                  endIndent: 16,
                ),
                CustomSwitchTile(
                  title: 'Metro',
                  secondary: Icon(TransportMode.subway.icon),
                  value: state.transportModes.contains(TransportMode.subway),
                  onChanged: (_) {
                    settingPanelCubit.setTransportMode(TransportMode.subway);
                  },
                ),
                const Divider(
                  thickness: 2,
                  endIndent: 16,
                ),
                CustomSwitchTile(
                  title: 'Carpool',
                  secondary: Icon(TransportMode.car.icon),
                  value: state.transportModes.contains(TransportMode.car),
                  onChanged: (_) {
                    settingPanelCubit.setTransportMode(TransportMode.car);
                  },
                ),
                const Divider(
                  thickness: 2,
                  endIndent: 16,
                ),
                CustomSwitchTile(
                  title: 'Sharing',
                  secondary: Icon(TransportMode.bicycle.icon),
                  value: state.transportModes.contains(TransportMode.bicycle),
                  onChanged: (_) {
                    settingPanelCubit.setTransportMode(TransportMode.bicycle);
                  },
                ),
                if (state.transportModes.contains(TransportMode.bicycle))
                  Container(
                    margin: const EdgeInsets.only(left: 55, top: 5, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                          child: Text('Citybikes', style: theme.textTheme.bodyText1),
                        ),
                        CustomSwitchTile(
                          title: 'RegioRad',
                          secondary: Icon(TransportMode.bicycle.icon),
                          value: state.bikeRentalNetworks.contains(BikeRentalNetwork.regioRad),
                          onChanged: (_) {
                            settingPanelCubit.setBikeRentalNetwork(BikeRentalNetwork.regioRad);
                          },
                        ),
                        CustomSwitchTile(
                          title: 'Taxi',
                          secondary: Icon(TransportMode.bicycle.icon),
                          value: state.bikeRentalNetworks.contains(BikeRentalNetwork.taxi),
                          onChanged: (_) {
                            settingPanelCubit.setBikeRentalNetwork(BikeRentalNetwork.taxi);
                          },
                        ),
                        CustomSwitchTile(
                          title: 'CarSharing',
                          secondary: Icon(TransportMode.bicycle.icon),
                          value: state.bikeRentalNetworks.contains(BikeRentalNetwork.carSharing),
                          onChanged: (_) {
                            settingPanelCubit.setBikeRentalNetwork(BikeRentalNetwork.carSharing);
                          },
                        ),
                      ],
                    ),
                  )
                else
                  Container(),
                CustomSwitchTile(
                  title: 'Avoid transfers',
                  value: state.avoidTransfers,
                  onChanged: (value) => settingPanelCubit.setAvoidTransfers(avoidTransfers: value),
                ),
                const Divider(thickness: 10),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('My modes of transport', style: theme.textTheme.bodyText1),
                ),
                CustomSwitchTile(
                  title: 'Bike',
                  secondary: Icon(TransportMode.bicycle.icon),
                  value: state.includeBikeSuggestions,
                  onChanged: (value) =>
                      settingPanelCubit.setIncludeBikeSuggestions(includeBikeSuggestions: value),
                ),
                if (state.includeBikeSuggestions)
                  Container(
                    margin: const EdgeInsets.only(
                      left: 55,
                    ),
                    child: CustomExpansionTile(
                      title: "Biking speed",
                      options: const [
                        '10 Km/h',
                        '15 Km/h',
                        '20 Km/h',
                        '25 Km/h',
                        '30 Km/h',
                      ],
                      textSelected: state.typeBikingSpeed.name,
                      onChanged: (value) {
                        switch (value) {
                          case '10 Km/h':
                            settingPanelCubit.setBikingSpeed(BikingSpeed.slow);
                            break;
                          case '15 Km/h':
                            settingPanelCubit.setBikingSpeed(BikingSpeed.calm);
                            break;
                          case '20 Km/h':
                            settingPanelCubit.setBikingSpeed(BikingSpeed.average);
                            break;
                          case '25 Km/h':
                            settingPanelCubit.setBikingSpeed(BikingSpeed.prompt);
                            break;
                          case '30 Km/h':
                            settingPanelCubit.setBikingSpeed(BikingSpeed.fast);
                            break;
                          default:
                        }
                      },
                    ),
                  )
                else
                  Container(),
                const Divider(thickness: 2),
                CustomSwitchTile(
                  title: 'Park and Ride',
                  secondary: Icon(TransportMode.bicycle.icon),
                  value: state.includeParkAndRideSuggestions,
                  onChanged: (value) => settingPanelCubit.setParkRide(parkRide: value),
                ),
                CustomSwitchTile(
                  title: 'Car',
                  secondary: Icon(TransportMode.car.icon),
                  value: state.includeCarSuggestions,
                  onChanged: (value) =>
                      settingPanelCubit.setIncludeCarSuggestions(includeCarSuggestions: value),
                ),
                const Divider(thickness: 10),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Accessibility', style: theme.textTheme.bodyText1),
                ),
                CustomSwitchTile(
                  title: 'Wheelchair',
                  secondary: Icon(TransportMode.car.icon),
                  value: state.wheelchair,
                  onChanged: (value) => settingPanelCubit.setWheelChair(wheelchair: value),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getTextWalkingSelect(BuildContext context, WalkingSpeed selected) {
    switch (selected) {
      case WalkingSpeed.slow:
        return 'Slow';
        break;
      case WalkingSpeed.calm:
        return 'Calm';
        break;
      case WalkingSpeed.average:
        return 'Average';
        break;
      case WalkingSpeed.prompt:
        return 'Prompt';
        break;
      case WalkingSpeed.fast:
        return 'Fast';
        break;
      default:
        return 'Fast';
    }
  }
}
