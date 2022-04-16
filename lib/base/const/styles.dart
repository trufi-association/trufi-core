// ignore: avoid_classes_with_only_static_members
class Insets {
  static double scale = 1;
  static double offsetScale = 1;

  // Regular paddings
  static double get xs => 4 * scale;

  static double get sm => 8 * scale;

  static double get med => 12 * scale;

  static double get lg => 16 * scale;

  static double get xl => 32 * scale;

  // Offset, used for the edge of the window, or to separate large sections in the app
  static double get offset => 40 * offsetScale;
}
