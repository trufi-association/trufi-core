import 'package:flutter/material.dart';
import 'package:trufi_core/base/widgets/alerts/base_modal_dialog.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';
import 'package:trufi_core/base/blocs/providers/city_selection_manager.dart';

enum RouteCityDecision {
  stayInCurrent,
  openInOther,
}

class RouteCityMismatchDialog extends StatelessWidget {
  static Future<bool> showModal(
    BuildContext context, {
    required CityInstance currentCity,
    required CityInstance targetCity,
  }) async {
    return (await showTrufiDialog<bool?>(
          context: context,
          barrierDismissible: true,
          builder: (_) => RouteCityMismatchDialog(
            currentCity: currentCity,
            targetCity: targetCity,
          ),
        )) ??
        false;
  }

  const RouteCityMismatchDialog({
    super.key,
    required this.currentCity,
    required this.targetCity,
  });

  final CityInstance currentCity;
  final CityInstance targetCity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentCityName = currentCity.getText;
    final targetCityName = targetCity.getText;

    return BaseModalDialog(
      width: double.infinity,
      hideCloseButton: true,
      title: 'La ruta que intentas abrir pertenece a otra ciudad.',
      infoButtonText: 'Puedes cambiar de ciudad cuando quieras.',
      contentBuilder: (context) {
        return Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Deseas quedarte en $currentCityName o abrir la ruta en $targetCityName?',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
      actionsBuilder: (context) {
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'Quedarme en $currentCityName',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Abrir en $targetCityName',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
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
