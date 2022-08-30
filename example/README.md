# Trufi Core Example

This implementation demonstrates how to use the trufi_core Flutter plugin to build your own public transport app. You can use this folder as a skeleton to start your own app. We assume you have a working [Flutter environment](https://flutter.dev/docs/get-started/install).

## Versions

The example was tested against Flutter 2.8.1 and might cause [problems with Flutter 3](https://github.com/trufi-association/trufi-core/issues/604).

## Set up the backend

The app needs to connect to a backend running on a server to be able to recommend routes. The app does not work without internet connection. But once it fetched the route it can operate without internet connection except for the map background tiles. So you can fetch your route at home and take your ride offline. But anyway you need a backend for the map background tiles and the routing at least. We build the backend called [trufi-server](https://github.com/trufi-association/trufi-server) which you can use. That backend just serves pre-generated data and that needs to be created. This is what we use [trufi-server-resources](https://github.com/trufi-association/trufi-server-resources) for.

That requires Linux. You will use Linux anyway on the production server later on. But you can run [Linux in a VM on Windows](https://www.wikihow.com/Install-Ubuntu-on-VirtualBox) or [on Mac](https://www.wikihow.com/Run-Linux-on-a-Mac) if you don’t use Linux natively. We use Debian or Debian favored systems like Ubuntu. Our backend has some debian related dependencies so better decide for Debian.

## Getting started

`pubspec.yaml` references `trufi_core`. Here we use a relative path, in your final application it should look more like this:

```yaml
  trufi_core:
    git:
      url: https://github.com/trufi-association/trufi-core
      ref: main
```

## Modify [lib/main.dart](./example/lib/main.dart)

`lib/main.dart` is used to bootstrap the application. It sets configuration values, theme colors and runs the app. That's it!

Our example uses a `assets/cfg/app_config.json` config to keep some values out of the `main.dart`. You will find a blank version you need to copy over. It is also possible to hardcode these values directly in `main.dart`.

### Search functionality

The app supports searching for POIs to start the journey from and to plan the journey to. That can happen offline or online. Offline has the advantage that it saves your user bandwidth because the search will not consume any data. But it comes with the huge disadvantages of having to release a new version of the app everytime you want to update the offline search index. Only use the offline search engine for small cities otherwise the performance of the app will suffer. Online comes with the advantage of always providing the users with a fresh search experience because you can change the index on the backend more frequently. The disadvantage is that the app sends every typed char to the backend through the internet possibly invading users privacy because every request gets logged. Use this if having internet connection does not prove to be any difficulty and internet connection is cheap as in most developed countries.

To use offline search POI functionality remove `photonUrl` and generate your own version of the `assets/data/search.json` using [osm-search-data-export](https://github.com/trufi-association/osm-search-data-export).

To use online search POI functionality remove `searchAssetPath`, set up the backend with the extension [photon](https://github.com/trufi-association/trufi-server/tree/main/extensions/photon) and the necessary builder [photon-data-builder](https://github.com/trufi-association/trufi-server-resources/tree/main/photon-data-builder). Of course you need to adapt the `photonUrl` value.

## Modify assets, theme and config

Make necessary modifications to [assets](assets), [theme](lib/theme) and config in the generated [Android](android) and [iOS](ios)  projects e.g, you will want to replace the app icon with yours. 

Don’t forget to change [assets/images/drawer-bg.jpg](assets/images/drawer-bg.jpg)

## Run and rock that thing

Start the application:

```sh
$ flutter run
```

## Additional notes

* If you use MapTiler Cloud as your tiles endpoint you can pass in your [MapTiler key](https://cloud.maptiler.com/account/keys) via the `trufiCfg.map.mapTilerKey` setting.

* For Android: [Create a key store](https://flutter.dev/docs/deployment/android#signing-the-app) or use an existing key, fill the `android/key.properties` with path and password.
