import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Alerta para cuando los servicios de ubicación del dispositivo están desactivados.
/// En mobile ofrece abrir los ajustes del sistema de ubicación.
class AlertLocationServicesDenied extends StatelessWidget {
  const AlertLocationServicesDenied({super.key, this.onOpenSettings});

  final Future<void> Function()? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubicación desactivada'),
      content: const Text(
        'Los servicios de ubicación del dispositivo están desactivados. '
        'Actívalos para usar tu ubicación en el mapa.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (!kIsWeb)
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (onOpenSettings != null) {
                await onOpenSettings!.call();
              }
            },
            child: const Text('Abrir ajustes'),
          ),
      ],
    );
  }
}

/// Variante simple para Web donde no hay intent directo a ajustes del SO.
class AlertLocationServicesDeniedWeb extends StatelessWidget {
  const AlertLocationServicesDeniedWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Ubicación desactivada'),
      content: Text(
        'El navegador no tiene habilitados los servicios de ubicación. '
        'Revisa los permisos del sitio en tu navegador.',
      ),
    );
  }
}