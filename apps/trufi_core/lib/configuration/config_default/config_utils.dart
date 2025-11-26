abstract class ConfigUtils {
  static double findNearestOption(double value, List<double> options) {
    double currNearest = options[0];
    double diff = (value - currNearest).abs();

    for (double option in options) {
      double newDiff = (value - option).abs();
      if (newDiff < diff) {
        diff = newDiff;
        currNearest = option;
      }
    }
    return currNearest;
  }
}
