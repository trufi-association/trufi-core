// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class CoreLocalizationsEs extends CoreLocalizations {
  CoreLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Trufi App';

  @override
  String get appLoading => 'Cargando...';

  @override
  String get navHome => 'Inicio';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navFeedback => 'Comentarios';

  @override
  String get navSettings => 'Configuración';

  @override
  String get navAbout => 'Acerca de';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get errorGeneric => 'Ocurrió un error';

  @override
  String get errorNetwork => 'Error de red. Por favor verifica tu conexión.';

  @override
  String get errorInitialization => 'Error al inicializar la aplicación';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get errorPageNotFound => 'Página no encontrada';

  @override
  String get actionGoHome => 'Ir al inicio';

  @override
  String get titleError => 'Error';

  @override
  String unreadCount(int count) {
    return '$count sin leer';
  }

  @override
  String get markAllAsRead => 'Marcar todo como leído';
}
