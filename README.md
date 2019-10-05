# Trufi App

The mobile app for public transportation.
Built in [Flutter](https://flutter.dev/) and made by the Trufi Association, a social startup, to provide smartphone apps for informal traffic.

[<img alt="Trufi Logo" src="trufi.svg" width="120" />](https://www.trufi-association.org/)

Please **[visit the website](https://www.trufi-association.org/)** for more information!

[<img alt="Twitter Logo" src="https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/twitter.svg" width="16" style="padding-right:4px" /> Follow @TrufiAssoc](https://twitter.com/TrufiAssoc)

If you find any issues within this app, please report them at [the issue tracker](https://github.com/trufi-association/trufi-app/issues). Contributions are both encouraged and appreciated.

## Screenshots

<img src="https://www.trufi.app/wp-content/uploads/2019/02/device_pixel-497x1024.png" width="200" hspace="20"/><img src="https://www.trufi.app/wp-content/uploads/2019/02/device_iphone-507x1024.png" width="200" hspace="20" />

## Get the Trufi App

The mobile application is currently available for the following cities:

* Cochabamba, Bolivia - [Website](https://www.trufi.app), [Google Play](https://play.google.com/store/apps/details?id=app.trufi.navigator), iOS coming soon
* Accra, Ghana - [Website](https://www.trotro.app/), [Google Play](https://play.google.com/store/apps/details?id=com.trotro.trotro), iOS coming soon

Please contact the [Trufi Association](mailto:info@trufi-association.org) to get one for your city, too.

## Building From Source

If you want to start working on the Trufi App. Get started by reviewing the [Flutter documentation](https://flutter.dev) first. Then you can follow the next steps:

* [Install the enviroment](https://flutter.dev/docs/get-started/install)
* Close the the source code repository: `$ git clone https://github.com/trufi-association/trufi-app.git`
* Copy the configuration file: `$ cp assets/cfg/app_config.json.dist assets/cfg/app_config.json`
* Update the configuration and add your private [MapTiler key](https://cloud.maptiler.com/account/keys)
* For Android: [Create a key store](https://flutter.dev/docs/deployment/android#signing-the-app) or use an existing key, fill the `android/key.properties` with path and password.
* Build a test version of the application with `$ flutter run`

## Free Software

Copyright 2019 - [Trufi Association](https://www.trufi-association.org/)

This program is free software: you can redistribute it and/or modify it under the terms of the [GNU General Public License version 3](./LICENSE) as published by the Free Software Foundation.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
