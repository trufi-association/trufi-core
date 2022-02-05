import 'package:flare_flutter/flare_actor.dart';

class AnimationConfiguration {
  final FlareActor loading;
  final FlareActor success;

  AnimationConfiguration({
    this.loading = const FlareActor(
      "assets/images/loading.flr",
      animation: "Trufi Drive",
    ),
    this.success = const FlareActor(
      "assets/images/success.flr",
      animation: "Untitled",
    ),
  });
}
