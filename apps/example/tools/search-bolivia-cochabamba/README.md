# search-bolivia-cochabamba (example)

Generates the example app's **offline search data** — POIs, streets and
**street junctions** — with
[`trufi-association/osm-search-data-export`](https://github.com/trufi-association/osm-search-data-export)
as a Node library. The pinned version lives in [`package.json`](package.json).

## Why it exists

In cities without street numbers people say *"Ayacucho y Heroínas"*. The old
Trufi Core searched a street and then offered its junctions; the flow lost its
data source in the v5 migration
([#745](https://github.com/trufi-association/trufi-core/issues/745)). This tool
regenerates that data so a city app can ship it.

## Run

```bash
npm install --ignore-scripts   # see note below
npm start                      # Overpass, self-contained
SOURCE=pbf PBF_FILE=/path/to/city.osm.pbf npm start   # faster for repeat runs
```

Output: `./out/search.json` (`json-compact` shape, ~2.6 MB for Cochabamba:
~15k POIs, ~4k streets, ~23k junctions).

## Notes

- **`--ignore-scripts`**: the exporter pulls `better-sqlite3` for its optional
  SQLite output, whose native build fails on recent Node. We only use the JSON
  output, so skipping the build is enough.
- Overpass is rate-limited: for repeated runs use a PBF extract.
- Generating is not shipping: copy `out/search.json` into the app's assets and
  bump its version, or the app keeps the old data (same trap as the GTFS
  refresh).
