import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/other_icons.dart';
import 'package:trufi_core/widgets/custom_switch_tile.dart';
import 'package:trufi_core/widgets/speed_expanded_tile.dart';

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
        title: Text(localization.commonSettings),
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
                SpeedExpansionTile(
                  title: localization.settingPanelWalkingSpeed,
                  dataSpeeds: WalkingSpeed.values
                      .map(
                        (e) =>
                            DataSpeed(e.translateValue(localization), e.speed),
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
                  title: localization.settingPanelAvoidWalking,
                  value: state.avoidWalking,
                  onChanged: (value) =>
                      payloadDataPlanCubit.setAvoidWalking(avoidWalking: value),
                ),
                _dividerWeight,
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    localization.settingPanelTransportModes,
                    style: theme.textTheme.bodyText1,
                  ),
                  CustomExpansionTile(
                    title: localization.settingPanelWalkingSpeed,
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
                    title: localization.settingPanelAvoidWalking,
                    value: state.avoidWalking,
                    onChanged: (value) => payloadDataPlanCubit.setAvoidWalking(
                        avoidWalking: value),
                  ),
                  _dividerWeight,
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      localization.settingPanelTransportModes,
                      style: theme.textTheme.bodyText1,
                    ),
                  ),
                  CustomSwitchTile(
                    title: localization.instructionVehicleBus,
                    secondary: Container(
                      decoration: BoxDecoration(
                          color: TransportMode.bus.color,
                          borderRadius: BorderRadius.circular(5)),
                      height: 35,
                      width: 35,
                      child: TransportMode.bus.getImage(color: Colors.white),
                    ),
                    value: state.transportModes.contains(TransportMode.bus),
                    onChanged: (_) {
                      payloadDataPlanCubit.setTransportMode(TransportMode.bus);
                    },
                  ),
                  _divider,
                  CustomSwitchTile(
                    title: localization.instructionVehicleCommuterTrain,
                    secondary: Container(
                      decoration: BoxDecoration(
                          color: TransportMode.rail.color,
                          borderRadius: BorderRadius.circular(5)),
                      height: 35,
                      width: 35,
                      child: TransportMode.rail.getImage(color: Colors.white),
                    ),
                    value: state.transportModes.contains(TransportMode.rail),
                    onChanged: (_) {
                      payloadDataPlanCubit.setTransportMode(TransportMode.rail);
                    },
                  ),
                  _divider,
                  CustomSwitchTile(
                    title: localization.instructionVehicleMetro,
                    secondary: Container(
                      decoration: BoxDecoration(
                          color: TransportMode.subway.color,
                          borderRadius: BorderRadius.circular(5)),
                      height: 35,
                      width: 35,
                      child: TransportMode.subway.getImage(color: Colors.white),
                    ),
                    value: state.transportModes.contains(TransportMode.subway),
                    onChanged: (_) {
                      payloadDataPlanCubit
                          .setTransportMode(TransportMode.subway);
                    },
                  ),
                  _divider,
                  CustomSwitchTile(
                    title: localization.instructionVehicleCarpool,
                    secondary: SizedBox(
                      height: 35,
                      width: 35,
                      child: TransportMode.carPool.getImage(),
                    ),
                    value: state.transportModes.contains(TransportMode.carPool),
                    onChanged: (_) {
                      payloadDataPlanCubit
                          .setTransportMode(TransportMode.carPool);
                    },
                  ),
                  _divider,
                  CustomSwitchTile(
                    title: localization.instructionVehicleSharing,
                    secondary: SizedBox(
                      height: 35,
                      width: 35,
                      child: BikeRentalNetwork.regioRad.image,
                    ),
                    value: state.transportModes.contains(TransportMode.bicycle),
                    onChanged: (_) {
                      payloadDataPlanCubit
                          .setTransportMode(TransportMode.bicycle);
                    },
                  ),
                  if (state.transportModes.contains(TransportMode.bicycle))
                    Container(
                      margin:
                          const EdgeInsets.only(left: 55, top: 5, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 5),
                            child: Text(localization.commonCitybikes,
                                style: theme.textTheme.bodyText1),
                          ),
                          CustomSwitchTile(
                            title:
                                localization.instructionVehicleSharingRegioRad,
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
                            title: localization.instructionVehicleSharingTaxi,
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
                            title: localization
                                .instructionVehicleSharingCarSharing,
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
                    title: localization.settingPanelAvoidTransfers,
                    value: state.avoidTransfers,
                    onChanged: (value) => payloadDataPlanCubit
                        .setAvoidTransfers(avoidTransfers: value),
                  ),
                  _dividerWeight,
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(localization.settingPanelMyModesTransport,
                        style: theme.textTheme.bodyText1),
                  ),
                  CustomSwitchTile(
                    title: localization.settingPanelMyModesTransportBike,
                    secondary: SizedBox(
                      height: 35,
                      width: 35,
                      child: bikeSvg(),
                    ),
                    child: SpeedExpansionTile(
                      title: localization.settingPanelBikingSpeed,
                      dataSpeeds: BikingSpeed.values
                          .map(
                            (e) =>
                                DataSpeed(e.translateValue(localization), ''),
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
                    value: state.includeParkAndRideSuggestions,
                    onChanged: (value) =>
                        payloadDataPlanCubit.setParkRide(parkRide: value),
                  ),
                  CustomSwitchTile(
                    title: localization.instructionVehicleCar,
                    secondary: SizedBox(
                      height: 35,
                      width: 35,
                      child: carSvg(),
                    ),
                    value: state.includeCarSuggestions,
                    onChanged: (value) => payloadDataPlanCubit
                        .setIncludeCarSuggestions(includeCarSuggestions: value),
                  ),
                  _dividerWeight,
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(localization.settingPanelAccessibility,
                        style: theme.textTheme.bodyText1),
                  ),
                  CustomSwitchTile(
                    title: localization.settingPanelWheelchair,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
