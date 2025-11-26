

import 'package:trufi_core/configuration/config_default/config_default.dart';
import 'package:trufi_core/configuration/config_default/config_default/city_bike_config.dart';
import 'package:trufi_core/configuration/config_default/config_default/mode_utils.dart';

class CityBikeUtils {
  // ignore: constant_identifier_names
  static const String DEFAULT_FORM_FACTOR = "bicycle";
  // ignore: constant_identifier_names
  static const String DEFAULT_OPERATOR = "other";

  static List<String> toggleSharingOperator({
    required String newValue,
    required ConfigData config,
    required List<String>? allowedVehicleRentalNetworks,
  }) {
    List<String> currentOperators = getCurrentSharingOperators(
      config: config,
      formFactor: null,
      allowedVehicleRentalNetworks: allowedVehicleRentalNetworks,
    );

    Set<String> chosenOperators;

    // Toggle the selected operator
    if (currentOperators.contains(newValue)) {
      chosenOperators = currentOperators.toSet()..remove(newValue);
    } else {
      chosenOperators = currentOperators.toSet()..add(newValue);
    }

    return getNetworkIdsByOperatorIds(chosenOperators, config);
  }

  static List<String> getNetworkIdsByOperatorIds(
      Set<String> operatorIds, ConfigData config) {
    return config.cityBike.networks!.keys.where((networkId) {
      String operator =
          config.cityBike.networks?[networkId]?.operator ?? DEFAULT_OPERATOR;
      return operatorIds.contains(operator);
    }).toList();
  }

  static List<String> getCurrentSharingOperators({
    required ConfigData config,
    required String? formFactor,
    List<String>? allowedVehicleRentalNetworks,
  }) {
    assertSharingIsInitialized(config);

    List<String> allCurrentNetworks = getCitybikeNetworks(
      config,
      allowedVehicleRentalNetworks,
    );

    return allCurrentNetworks
        .where((networkId) => formFactor != null
            ? (config.cityBike.networks?[networkId]?.formFactors ?? <String>[])
                .contains(formFactor)
            : true)
        .map(
          (networkId) =>
              config.cityBike.networks?[networkId]?.operator?.isNotEmpty ??
                      false
                  ? config.cityBike.networks![networkId]!.operator!
                  : DEFAULT_OPERATOR,
        )
        .toList();
  }

  static List<String> getCitybikeNetworks(
    ConfigData config,
    List<String>? allowedVehicleRentalNetworks,
  ) {
    List<String> defaultNetworks = getDefaultNetworks(config);

    if (allowedVehicleRentalNetworks != null) {
      return allowedVehicleRentalNetworks
          .where((networkId) => defaultNetworks.contains(networkId))
          .toList();
    }

    return defaultNetworks;
  }

  static List<OperatorConfig> getSharingOperatorsByFormFactor(
    String formFactor,
    ConfigData config,
  ) {
    assertSharingIsInitialized(config);

    return mapOperators(
      config.cityBike.formFactors![formFactor]?.operatorIds,
      config,
    );
  }

  static List<OperatorConfig> mapOperators(
      Set<String>? operatorIds, ConfigData config) {
    if (operatorIds == null) return [];

    return operatorIds
        .map((operatorId) => config.cityBike.operators?[operatorId])
        .whereType<OperatorConfig>()
        .toList();
  }

  static void assertSharingIsInitialized(ConfigData config) {
    var formFactors = config.cityBike.formFactors;
    if (formFactors == null ||
        formFactors.isEmpty ||
        formFactors.values.firstOrNull?.operatorIds == null) {
      initializeSharingConfig(config);
    }
  }

  static void initializeSharingConfig(ConfigData config) {
    initializeFormFactors(config);
    initializeOperators(config);
    initializeOperatorAndNetworkdIds(config);
  }

  static void initializeFormFactors(ConfigData config) {
    // Ensure formFactors is initialized
    config.cityBike.formFactors ??= <String, FormFactor>{};

    // Ensure DEFAULT_FORM_FACTOR exists in formFactors
    config.cityBike.formFactors!
        .putIfAbsent(DEFAULT_FORM_FACTOR, () => FormFactor());

    // Get all active network IDs
    List<String> allNetworkIds = getDefaultNetworks(config);

    for (var networkId in allNetworkIds) {
      var network = config.cityBike.networks?[networkId];

      // Initialize formFactors from type or set to default
      if (network?.formFactors?.isEmpty ?? true) {
        network?.formFactors = [
          network.type == 'citybike'
              ? 'bicycle'
              : network.type ?? DEFAULT_FORM_FACTOR
        ];
      }

      for (var formFactor in network?.formFactors ?? <String>[]) {
        config.cityBike.formFactors!
            .putIfAbsent(formFactor, () => FormFactor());
      }
    }

    // Ensure every FormFactor has a set of operatorIds and networkIds
    config.cityBike.formFactors!.forEach((_, formFactorConfig) {
      formFactorConfig.operatorIds = <String>{};
      formFactorConfig.networkIds = <String>{};
    });
  }

  static void initializeOperators(ConfigData config) {
    // Ensure operators map is initialized
    config.cityBike.operators ??= {};
    if (config.cityBike.operators == null) {
      config.cityBike.operators = {};
      // Ensure DEFAULT_OPERATOR exists
      config.cityBike.operators![DEFAULT_OPERATOR] = OperatorConfig(
        operatorId: DEFAULT_OPERATOR,
      );
    }

    // Assign operatorId to each operator
    config.cityBike.operators!.forEach((operatorId, operator) {
      operator.operatorId = operatorId;
    });
  }

  static void initializeOperatorAndNetworkdIds(ConfigData config) {
    // Get all active network IDs
    List<String> allNetworkIds = getDefaultNetworks(config);

    for (var networkId in allNetworkIds) {
      var network = config.cityBike.networks?[networkId];

      // Retrieve operator or assign default if not configured
      String operator = (network?.operator != null &&
              network!.operator!.isNotEmpty &&
              (config.cityBike.operators?.containsKey(network.operator) ??
                  false))
          ? network.operator!
          : DEFAULT_OPERATOR;

      List<String> formFactorList =
          network?.formFactors != null && network!.formFactors!.isNotEmpty
              ? network.formFactors!
              : [DEFAULT_FORM_FACTOR];

      for (var formFactor in formFactorList) {
        // Ensure formFactor exists in config
        config.cityBike.formFactors?.putIfAbsent(
            formFactor,
            () => FormFactor(
                  operatorIds: <String>{},
                  networkIds: <String>{},
                ));

        config.cityBike.formFactors?[formFactor]?.operatorIds?.add(operator);
        config.cityBike.formFactors?[formFactor]?.networkIds?.add(networkId);
      }
    }

    // Sort operators alphabetically and move DEFAULT_OPERATOR to the end
    config.cityBike.formFactors?.forEach((_, formFactorConfig) {
      List<String> sortedOperators =
          (formFactorConfig.operatorIds?.toList() ?? [])..sort();
      int index = sortedOperators.indexOf(DEFAULT_OPERATOR);

      if (index != -1) {
        sortedOperators.removeAt(index);
        sortedOperators.add(DEFAULT_OPERATOR);
      }

      formFactorConfig.operatorIds = sortedOperators.toSet();
    });
  }

  static List<String> getDefaultNetworks(ConfigData config) {
    // TODO: Rename to activeNetworksIds
    List<String> mappedNetworks = [];

    config.cityBike.networks?.forEach((id, network) {
      if (ModeUtils.citybikeRoutingIsActive(network)) {
        mappedNetworks.add(id);
      }
    });

    return mappedNetworks;
  }
}
