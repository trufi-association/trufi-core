# Trufi Core Example

This implementation demonstrates how to use the trufi_core Flutter plugin to build your own public transport app. You can use this folder as a skeleton to start your own app. We assume you have a working [Flutter environment](https://flutter.dev/docs/get-started/install).

## Getting started

`pubspec.yaml` references `trufi_core`. Here we use a relative path, in your final application it should look more like this:

```yaml
  trufi_core:
    git:
      url: https://github.com/trufi-association/trufi-core
      ref: master
```

`lib/main.dart` is used to bootstrap the application. It sets configuration values and theme colors and runs the app. That's it! You then only have to set up assets and config in the generated iOS and Android projects.

Our example uses a `assets/cfg/app_config.json` config to keep some values out of the `main.dart`. You will find a blank version you need to copy over. It is also possible to hardcode these values directly in `main.dart`.

Start the application:

```sh
$ flutter run
```

## Additional notes

* If you use MapTiler Cloud as your tiles endpoint you can pass in your [MapTiler key](https://cloud.maptiler.com/account/keys) via the `trufiCfg.map.mapTilerKey` setting.

* For Android: [Create a key store](https://flutter.dev/docs/deployment/android#signing-the-app) or use an existing key, fill the `android/key.properties` with path and password.
