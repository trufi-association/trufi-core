import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class CustomButton extends StatefulWidget {
  final Leg leg;
  final List<SelectedData> options;
  const CustomButton({
    super.key,
    required this.leg,
    required this.options,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  SelectedData? selectedData;

  @override
  void initState() {
    selectedData = widget.options[1];
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
          color: selectedData == null
              ? theme.colorScheme.secondary.withOpacity(0.1)
              : null,
        ),
        child: InkWell(
          onTap: () async {
            final selectedValue = await SingleSelectionOption.selectPosition(
              context,
              leg: widget.leg,
              title: "How crowded is it on board?",
              selectedData: selectedData,
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
                selectedData != null ? Icons.check : Icons.people_alt,
                size: 15,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(
                width: 5,
              ),
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyText2,
                  // text: '${localizationA.aboutOpenSource} ',
                  children: [
                    if (selectedData != null)
                      TextSpan(
                        text: "Live ",
                        style: theme.textTheme.bodyText2?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    TextSpan(
                      text: selectedData != null
                          ? selectedData!.name
                          : "Not too crowded",
                      style: theme.textTheme.bodyText2?.copyWith(
                        color: selectedData != null
                            ? theme.colorScheme.secondary
                            : null,
                      ),
                    ),
                  ],
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

class SelectedData extends Equatable {
  final String name;
  final String description;
  final IconData icon;
  final bool isSelected;

  const SelectedData(
    this.name,
    this.description,
    this.icon,
    this.isSelected,
  );

  @override
  List<Object?> get props => [name, description, isSelected];
}

class SingleSelectionOption extends StatefulWidget {
  static Future<SelectedData?> selectPosition(
    BuildContext buildContext, {
    required Leg leg,
    required String title,
    required SelectedData? selectedData,
    required List<SelectedData> options,
  }) async {
    return await showTrufiDialog<SelectedData?>(
      context: buildContext,
      builder: (BuildContext context) => SingleSelectionOption(
        leg: leg,
        title: title,
        selectedData: selectedData,
        options: options,
      ),
    );
  }

  final Leg leg;
  final String title;
  final SelectedData? selectedData;
  final List<SelectedData> options;
  const SingleSelectionOption({
    super.key,
    required this.leg,
    required this.title,
    required this.selectedData,
    required this.options,
  });

  @override
  State<SingleSelectionOption> createState() => _SingleSelectionOptionState();
}

class _SingleSelectionOptionState extends State<SingleSelectionOption> {
  SelectedData? selectedData;

  @override
  void initState() {
    selectedData = widget.selectedData ?? widget.options[1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              Stack(
                children: [
                  Positioned(
                    left: 16,
                    child: InkWell(
                      onTap: () =>
                          Navigator.of(context).pop(widget.selectedData),
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
              ...widget.options.map(
                (e) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: TileSigleSelection(
                    data: e,
                    selectedData: selectedData,
                    onChanged: (data) {
                      setState(() {
                        selectedData = data;
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
                Navigator.of(context).pop(selectedData);
              },
            ),
          )
        ],
      ),
    );
  }
}

class TileSigleSelection extends StatelessWidget {
  final SelectedData data;
  final SelectedData? selectedData;
  final ValueChanged<SelectedData?> onChanged;
  const TileSigleSelection({
    super.key,
    required this.data,
    required this.selectedData,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (data == selectedData) {
          onChanged(null);
        } else {
          onChanged(data);
        }
      },
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(
            data.icon,
            color: data == selectedData ? theme.colorScheme.secondary : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name),
                Text(data.description),
              ],
            ),
          ),
          Radio(
            value: data,
            groupValue: selectedData,
            onChanged: (value) {
              if (data == selectedData) {
                onChanged(null);
              } else {
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
