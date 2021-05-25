# Trufi Core

[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/trufi-association/trufi-app/issues)
[![Twitter Follow](https://img.shields.io/twitter/follow/TrufiAssoc?style=social)](https://twitter.com/TrufiAssoc)
[![Flutter Test](https://github.com/trufi-association/trufi-core/actions/workflows/flutter_test.yml/badge.svg?branch=master)](https://github.com/trufi-association/trufi-core/actions/workflows/flutter_test.yml)

A cross-plattform multi-modal public transport app based on open data.
Built in [Flutter](https://flutter.dev/) by the [Trufi Association](https://www.trufi-association.org/), a social startup.

[<img alt="Trufi Logo" src="trufi.svg" width="120" />](https://www.trufi-association.org/)

## Screenshots

<img src="https://www.trufi.app/wp-content/uploads/2019/02/device_pixel-497x1024.png" width="200" hspace="20"/><img src="https://www.trufi.app/wp-content/uploads/2019/02/device_iphone-507x1024.png" width="200" hspace="20" />

## Get the Trufi App

The mobile application is currently available for the following cities:

* Cochabamba, Bolivia - [Website](https://www.trufi.app), [Google Play](https://play.google.com/store/apps/details?id=app.trufi.navigator), [App Store](https://apps.apple.com/bo/app/trufi/id1471411924)
* Accra, Ghana - [Website](https://www.trotro.app/), [Google Play](https://play.google.com/store/apps/details?id=com.trotro.trotro), [App Store](https://apps.apple.com/bo/app/trotro/id1478620071)

Please contact the [Trufi Association](https://www.trufi-association.org/contact/) to get one for your city, too.

## Getting started

Trufi Core is the base dependency used to create your public transport app. Have a look at the [example](example) implementation that contains further instructions.

### Translations
Do not modify the files in [/translations](/translations) they are managed from Lokalise.
If you need to update the translations checkout the [Translations Update Guide](https://github.com/trufi-association/trufi-core/wiki/Translations-Update-Guide)
Please reach out to the [Contributers](https://github.com/trufi-association/trufi-core/graphs/contributors) to get access.
    
If you need to overwrite translations of the Host app checkout the following article [here](https://github.com/trufi-association/trufi-core/wiki/Custom-Translations).

## Complementary projects

[osm-search-data-export](https://github.com/trufi-association/osm-search-data-export) - Generates offline search data that includes POIs, streets and street junctions. The app currently uses the json-compact format.

[osm-public-transport-export](https://github.com/trufi-association/osm-public-transport-export) - Fetches OSM data and generates GeoJSON and additional files.

[geojson-to-gtfs](https://github.com/trufi-association/geojson-to-gtfs) - Turns generated GeoJSON and additional data into GTFS.

[gtfs-bolivia-cochabamba](https://github.com/trufi-association/gtfs-bolivia-cochabamba) - Config package that internally uses *osm-public-transport-export* and *geojson-to-gtfs* to generate a GTFS file to be used in OTP. Use this as a template to generate your own GTFS.

[OpenTripPlanner](https://github.com/opentripplanner/OpenTripPlanner) - Trip planning server that uses GTFS feeds for routing.

## Free Software

Copyright 2020 - [Trufi Association](https://www.trufi-association.org/)

This program is free software: you can redistribute it and/or modify it under the terms of the [GNU General Public License version 3](./LICENSE) as published by the Free Software Foundation.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

## Shout-outs
Big thanks to [<img src="https://avatars2.githubusercontent.com/u/14294501?s=200&v=4" alt="" width="16" valign="-3px" /> Lokalise](https://lokalise.com) for supporting our localization efforts with a free Open Source Enterprise plan.
Thanks to the [FMI - Finnish Meteorological Institute](https://en.ilmatieteenlaitos.fi/open-data) for the Open Weather Data