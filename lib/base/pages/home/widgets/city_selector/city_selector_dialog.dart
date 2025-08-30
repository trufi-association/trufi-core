import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/providers/city_selection_manager.dart';
import 'package:trufi_core/base/widgets/alerts/base_modal_dialog.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class CitySelectorDialog extends StatelessWidget {
  static Future<CityInstance?> showModal(
    BuildContext buildContext, {
    bool hideCloseButton = true,
    bool barrierDismissible = true,
  }) async =>
      await showTrufiDialog<CityInstance?>(
        context: buildContext,
        barrierDismissible: barrierDismissible,
        builder: (context) =>
            CitySelectorDialog(hideCloseButton: hideCloseButton),
      );

  const CitySelectorDialog({super.key, required this.hideCloseButton});

  final bool hideCloseButton;
  @override
  Widget build(BuildContext context) {
    return BaseModalDialog(
      width: double.infinity,
      hideCloseButton: hideCloseButton,
      title: 'Elige una ciudad',
      contentBuilder: (context) {
        return Material(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...CityInstance.values.map(
                (city) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(city),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      child: Center(
                        child: Text(
                          city.getText,
                          style:  TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
