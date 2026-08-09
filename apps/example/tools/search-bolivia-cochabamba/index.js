/**
 * Offline search data generator for the example app (Cochabamba).
 *
 * Uses osm-search-data-export as a library — the pinned version lives in
 * package.json. Output goes to ./out/search.json in the `json-compact`
 * shape that Trufi-Core apps expect.
 *
 * What it is for: street search and the street-junction flow ("Avenida
 * Ayacucho y Heroínas"), which is how people give directions in cities
 * without street numbers (#745).
 *
 * Source: Overpass by default so the tool is self-contained. A local PBF
 * is faster and kinder to the Overpass servers for repeated runs — set
 * PBF_FILE below and switch SOURCE to 'pbf'.
 */

const path = require('path');
const fs = require('fs');
const searchDataExport = require('osm-search-data-export');
const { pbfInput, overpassInput, jsonCompactOutput } = searchDataExport;

/** 'overpass' (no local files) or 'pbf' (fast, needs an extract). */
const SOURCE = process.env.SOURCE || 'overpass';

// south,west,north,east — Cochabamba's metropolitan area.
const BBOX = '-17.709721,-66.440262,-17.261759,-65.577835';
const PBF_FILE = process.env.PBF_FILE || path.join(__dirname, 'cochabamba.osm.pbf');
const OUT_FILE = path.join(__dirname, 'out', 'search.json');

// Check before building the input: pbfInput may open the file eagerly,
// and then the friendly message never gets printed.
if (SOURCE === 'pbf' && !fs.existsSync(PBF_FILE)) {
  console.error(`Missing ${PBF_FILE} — point PBF_FILE at an extract or use SOURCE=overpass.`);
  process.exit(1);
}

// out/ is gitignored, so a fresh clone doesn't have it.
fs.mkdirSync(path.dirname(OUT_FILE), { recursive: true });

const input = SOURCE === 'pbf'
  ? pbfInput({ inPath: PBF_FILE })
  : overpassInput({ bbox: BBOX });

console.log(`Generating search data from ${SOURCE}…`);

// The exporter is callback-driven: the input streams items and the output
// is called once on completion. It returns nothing, so the summary hangs
// off the output itself.
searchDataExport(input, (result) => {
  jsonCompactOutput({ outPath: OUT_FILE })(result);
  const data = JSON.parse(fs.readFileSync(OUT_FILE, 'utf8'));
  const streets = Object.keys(data.streets || {}).length;
  const junctions = Object.values(data.streetJunctions || {})
    .reduce((n, list) => n + list.length, 0);
  const size = (fs.statSync(OUT_FILE).size / 1024 / 1024).toFixed(1);
  console.log(
    `search.json: ${(data.pois || []).length} POIs, ${streets} streets, ` +
    `${junctions} junctions — ${size} MB`,
  );
});
