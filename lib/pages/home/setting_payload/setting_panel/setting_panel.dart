import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/other_icons.dart';
import 'package:trufi_core/widgets/custom_expanded_tile.dart';
import 'package:trufi_core/widgets/custom_switch_tile.dart';

class SettingPanel extends StatelessWidget {
  static const String route = "/setting-panel";
  static const Divider _divider = Divider(thickness: 2);
  static const Divider _dividerWeight = Divider(thickness: 10);

  const SettingPanel({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);

    final payloadDataPlanCubit = context.read<PayloadDataPlanCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(payloadDataPlanCubit.state);
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<PayloadDataPlanCubit, PayloadDataPlanState>(
          builder: (blocContext, state) {
            return ListView(
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                CustomExpansionTile(
                  title: "Walking speed",
                  options: WalkingSpeed.values
                      .map(
                        (e) => e.translateValue(localization),
                      )
                      .toList(),
                  textSelected:
                      state.typeWalkingSpeed.translateValue(localization),
                  onChanged: (value) {
                    final WalkingSpeed selected = WalkingSpeed.values
                        .firstWhere((element) =>
                            element.translateValue(localization) == value);
                    payloadDataPlanCubit.setWalkingSpeed(selected);
                  },
                ),
                _divider,
                CustomSwitchTile(
                  title: 'Avoid walking',
                  value: state.avoidWalking,
                  onChanged: (value) =>
                      payloadDataPlanCubit.setAvoidWalking(avoidWalking: value),
                ),
                _dividerWeight,
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      Text('Transport modes', style: theme.textTheme.bodyText1),
                ),
                CustomSwitchTile(
                  title: 'Bus',
                  secondary: SizedBox(
                    height: 35,
                    width: 35,
                    child: TransportMode.bus.image,
                  ),
                  value: state.transportModes.contains(TransportMode.bus),
                  onChanged: (_) {
                    payloadDataPlanCubit.setTransportMode(TransportMode.bus);
                  },
                ),
                _divider,
                CustomSwitchTile(
                  title: 'Commuter train',
                  secondary: SizedBox(
                    height: 35,
                    width: 35,
                    child: TransportMode.rail.image,
                  ),
                  value: state.transportModes.contains(TransportMode.rail),
                  onChanged: (_) {
                    payloadDataPlanCubit.setTransportMode(TransportMode.rail);
                  },
                ),
                _divider,
                CustomSwitchTile(
                  title: 'Metro',
                  secondary: SizedBox(
                    height: 35,
                    width: 35,
                    child: TransportMode.subway.image,
                  ),
                  value: state.transportModes.contains(TransportMode.subway),
                  onChanged: (_) {
                    payloadDataPlanCubit.setTransportMode(TransportMode.subway);
                  },
                ),
                _divider,
                CustomSwitchTile(
                  title: 'Carpool',
                  secondary: SizedBox(
                    height: 35,
                    width: 35,
                    child: TransportMode.carPool.image,
                  ),
                  value: state.transportModes.contains(TransportMode.carPool),
                  onChanged: (_) {
                    payloadDataPlanCubit
                        .setTransportMode(TransportMode.carPool);
                  },
                ),
                _divider,
                CustomSwitchTile(
                  title: 'Sharing',
                  secondary: SizedBox(
                    height: 35,
                    width: 35,
                    child: TransportMode.bicycle.image,
                  ),
                  value: state.transportModes.contains(TransportMode.bicycle),
                  onChanged: (_) {
                    payloadDataPlanCubit
                        .setTransportMode(TransportMode.bicycle);
                  },
                ),
                if (state.transportModes.contains(TransportMode.bicycle))
                  Container(
                    margin: const EdgeInsets.only(left: 55, top: 5, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 5),
                          child: Text('Citybikes',
                              style: theme.textTheme.bodyText1),
                        ),
                        CustomSwitchTile(
                          title: 'RegioRad',
                          secondary: SizedBox(
                            height: 35,
                            width: 35,
                            child: BikeRentalNetwork.regioRad.image,
                          ),
                          value: state.bikeRentalNetworks
                              .contains(BikeRentalNetwork.regioRad),
                          onChanged: (_) {
                            payloadDataPlanCubit.setBikeRentalNetwork(
                                BikeRentalNetwork.regioRad);
                          },
                        ),
                        CustomSwitchTile(
                          title: 'Taxi',
                          secondary: SizedBox(
                            height: 35,
                            width: 35,
                            child: BikeRentalNetwork.taxi.image,
                          ),
                          value: state.bikeRentalNetworks
                              .contains(BikeRentalNetwork.taxi),
                          onChanged: (_) {
                            payloadDataPlanCubit
                                .setBikeRentalNetwork(BikeRentalNetwork.taxi);
                          },
                        ),
                        CustomSwitchTile(
                          title: 'CarSharing',
                          secondary: SizedBox(
                            height: 35,
                            width: 35,
                            child: BikeRentalNetwork.carSharing.image,
                          ),
                          value: state.bikeRentalNetworks
                              .contains(BikeRentalNetwork.carSharing),
                          onChanged: (_) {
                            payloadDataPlanCubit.setBikeRentalNetwork(
                                BikeRentalNetwork.carSharing);
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
                  onChanged: (value) => payloadDataPlanCubit.setAvoidTransfers(
                      avoidTransfers: value),
                ),
                _dividerWeight,
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('My modes of transport',
                      style: theme.textTheme.bodyText1),
                ),
                CustomSwitchTile(
                  title: 'Bike',
                  secondary: const SizedBox(
                    height: 35,
                    width: 35,
                    child: Icon(Icons.pedal_bike),
                  ),
                  value: state.includeBikeSuggestions,
                  onChanged: (value) => payloadDataPlanCubit
                      .setIncludeBikeSuggestions(includeBikeSuggestions: value),
                ),
                if (state.includeBikeSuggestions)
                  Container(
                    margin: const EdgeInsets.only(
                      left: 55,
                    ),
                    child: CustomExpansionTile(
                      title: "Biking speed",
                      options: BikingSpeed.values
                          .map(
                            (e) => e.translateValue(localization),
                          )
                          .toList(),
                      textSelected:
                          state.typeBikingSpeed.translateValue(localization),
                      onChanged: (value) {
                        final BikingSpeed selected = BikingSpeed.values
                            .firstWhere((element) =>
                                element.translateValue(localization) == value);
                        payloadDataPlanCubit.setBikingSpeed(selected);
                      },
                    ),
                  )
                else
                  Container(),
                _divider,
                CustomSwitchTile(
                  title: 'Park and Ride',
                  secondary: SizedBox(
                    height: 35,
                    width: 35,
                    child: parkRideSvg,
                  ),
                  value: state.includeParkAndRideSuggestions,
                  onChanged: (value) =>
                      payloadDataPlanCubit.setParkRide(parkRide: value),
                ),
                CustomSwitchTile(
                  title: 'Car',
                  secondary: SizedBox(
                    height: 35,
                    width: 35,
                    child: carSvg,
                  ),
                  value: state.includeCarSuggestions,
                  onChanged: (value) => payloadDataPlanCubit
                      .setIncludeCarSuggestions(includeCarSuggestions: value),
                ),
                _dividerWeight,
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      Text('Accessibility', style: theme.textTheme.bodyText1),
                ),
                CustomSwitchTile(
                  title: 'Wheelchair',
                  secondary: SizedBox(
                    height: 35,
                    width: 35,
                    child: wheelChairSvg,
                  ),
                  value: state.wheelchair,
                  onChanged: (value) =>
                      payloadDataPlanCubit.setWheelChair(wheelchair: value),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }
}
