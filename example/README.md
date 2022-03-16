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

### Making necessary modifications

Edit [lib/main.dart](./lib/main.dart) and modify the necessary things. This is used to bootstrap the application. It sets configuration values and theme colors and runs the app. That's it! There are some aspects of it which we will describe a little bit more

#### Search POI functionality

In order to use offline search POI functionality you will need to remove `photonUrl` and generate your own version of the `assets/data/search.json` using [osm-search-data-export](https://github.com/trufi-association/osm-search-data-export). This has the disadvantage of having to create a new release of the app everytime you want to update that asset.

If you decide for the online search POI functionality which gives you greater flexibility e.g. more frequent updates of available POIs then remove `searchAssetPath`. This requires also a photon instance set up on a server. See [Photon Data Builder](https://github.com/trufi-association/trufi-server-resources/blob/main/photon-data-builder) of [trufi-server-resources](https://github.com/trufi-association/trufi-server-resources) and the [photon extension](https://github.com/trufi-association/trufi-server/tree/main/extensions/photon) of [trufi-server](https://github.com/trufi-association/trufi-server/tree/main/extensions/photon)

#### Change assets

Set up [assets](./assets) and the config in the generated iOS and Android projects. Our example uses a `assets/cfg/app_config.json` config to keep some values out of the `main.dart`. You will find a blank version you need to copy over. It is also possible to hardcode these values directly in `main.dart`.

### Start the application

```sh
$ flutter run
```

### Preparing the backend

The app requires connection to the internet to operate and thus needs a backend running on a linux server it can connect to. Trufi Association created two repositories about that topic to ease backend creation

- [trufi-server](https://github.com/trufi-association/trufi-server)
  Containing the actual backend which serves pre-generated data.
- [trufi-server-resources](https://github.com/trufi-association/trufi-server-resources)
  Containing the necessary code to build data that a [trufi-server](https://github.com/trufi-association/trufi-server) instance serves later on.

It is helpful to run Linux on your computer since the production server will be also running Linux. If you don’t use Linux in your everyday life you can run it in a VM

- [Run Linux in a VM on Windows](https://www.wikihow.com/Install-Ubuntu-on-VirtualBox)
- [Run Linux in a VM on Mac](https://www.wikihow.com/Run-Linux-on-a-Mac)

## Additional notes

* If you use MapTiler Cloud as your tiles endpoint you can pass in your [MapTiler key](https://cloud.maptiler.com/account/keys) via the `trufiCfg.map.mapTilerKey` setting.

* For Android: [Create a key store](https://flutter.dev/docs/deployment/android#signing-the-app) or use an existing key, fill the `android/key.properties` with path and password.
