import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class CustomButton2 extends StatefulWidget {
  final Leg leg;
  final List<MultiSelectedData> options;
  const CustomButton2({
    super.key,
    required this.leg,
    required this.options,
  });

  @override
  State<CustomButton2> createState() => _CustomButton2State();
}

class _CustomButton2State extends State<CustomButton2> {
  List<MultiSelectedData> ? selectedData;

  @override
  void initState() {
    // selectedData = widget.options[1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: selectedData != null
                ? theme.colorScheme.secondary
                : theme.iconTheme.color!,
          ),
          color: selectedData != null
              ? theme.colorScheme.secondary.withOpacity(0.1)
              : null,
        ),
        child: InkWell(
          onTap: () async {
            final selectedValue = await SingleSelectionOption.selectPosition(
              context,
              leg: widget.leg,
              title: "Is there security monitoring on board?",
              options: widget.options,
            );
            setState(() {
              selectedData = selectedValue;
            });
          },
          child: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Icon(
                selectedData != null ? Icons.check : Icons.error_outline,
                size: 15,
                color:
                    selectedData != null ? theme.colorScheme.secondary : null,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                selectedData != null
                    ? "Monitored security"
                    : "Security onboard",
                style: theme.textTheme.bodyText2?.copyWith(
                  color: selectedData != null
                      ? theme.colorScheme.secondary
                      : null,
                ),
              ),
              Icon(
                Icons.arrow_drop_down_rounded,
                color:
                    selectedData != null ? theme.colorScheme.secondary : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum DataState {
  notUsed,
  enabled,
  disabled,
}

extension DataStateExtension on DataState {
  static const _icons = <DataState, IconData?>{
    DataState.notUsed: Icons.add,
    DataState.enabled: Icons.check,
    DataState.disabled: Icons.error_outline,
  };

  IconData get icon => _icons[this] ?? Icons.error;

  DataState get nextData => this == DataState.notUsed
      ? DataState.enabled
      : this == DataState.enabled
          ? DataState.disabled
          : DataState.notUsed;
}

class MultiSelectedData extends Equatable {
  final String name;
  final DataState state;

  const MultiSelectedData(
    this.name,
    this.state,
  );

  MultiSelectedData copyWith({
    String? name,
    DataState? state,
  }) {
    return MultiSelectedData(
      name ?? this.name,
      state ?? this.state,
    );
  }

  @override
  List<Object?> get props => [name, state];
}

class SingleSelectionOption extends StatefulWidget {
  static Future<List<MultiSelectedData>?> selectPosition(
    BuildContext buildContext, {
    required Leg leg,
    required String title,
    required List<MultiSelectedData> options,
  }) async {
    return await showTrufiDialog<List<MultiSelectedData>?>(
      context: buildContext,
      builder: (BuildContext context) => SingleSelectionOption(
        leg: leg,
        title: title,
        options: options,
      ),
    );
  }

  final Leg leg;
  final String title;
  final List<MultiSelectedData> options;
  const SingleSelectionOption({
    super.key,
    required this.leg,
    required this.title,
    required this.options,
  });

  @override
  State<SingleSelectionOption> createState() => _SingleSelectionOptionState();
}

class _SingleSelectionOptionState extends State<SingleSelectionOption> {
  List<MultiSelectedData>? optionsTemp;

  @override
  void initState() {
    optionsTemp = widget.options;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Stack(
                children: [
                  Positioned(
                    left: 16,
                    child: InkWell(
                      onTap: () =>
                          Navigator.of(context).pop(widget.options),
                      child: const Icon(Icons.close),
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 5),
                          decoration: BoxDecoration(
                            color: widget.leg.backgroundColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            widget.leg.headSign,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.leg.fromPlace.name,
                          style: const TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                thickness: 3,
                color:
                    ThemeCubit.isDarkMode(theme) ? Colors.black : Colors.grey,
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...widget.options.map(
                (e) => Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: TileSigleSelection(
                    data: e,
                    onChanged: (data) {
                      setState(() {
                        if (optionsTemp!.contains(e)) {
                          final index = optionsTemp!.indexOf(e);
                          optionsTemp![index] = data!;
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              child: const Text(
                "Submit",
              ),
              onPressed: () {
                Navigator.of(context).pop(optionsTemp);
              },
            ),
          )
        ],
      ),
    );
  }
}

class TileSigleSelection extends StatelessWidget {
  final MultiSelectedData data;
  final ValueChanged<MultiSelectedData?> onChanged;
  const TileSigleSelection({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        onChanged(data.copyWith(state: data.state.nextData));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: data.state == DataState.notUsed
                ? const Color(0xFF000000)
                : data.state == DataState.enabled
                    ? theme.colorScheme.secondary
                    : Colors.red,
          ),
          color: data.state == DataState.notUsed
              ? null
              : data.state == DataState.enabled
                  ? theme.colorScheme.secondary.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 5,
              height: 25,
            ),
            Icon(
              data.state.icon,
              size: 15,
              color: data.state == DataState.notUsed
                  ? null
                  : data.state == DataState.enabled
                      ? theme.colorScheme.secondary
                      : Colors.red,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              data.name,
              style: theme.textTheme.bodyText2?.copyWith(
                color: data.state == DataState.notUsed
                    ? null
                    : data.state == DataState.enabled
                        ? theme.colorScheme.secondary
                        : Colors.red,
              ),
            ),
            const SizedBox(
              width: 8,
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}
