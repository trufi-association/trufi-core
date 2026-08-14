# Local OTP servers for the example app

Run the example fully serverless: the local Trufi planner already works
offline from the bundled GTFS, and with this runbook the two OTP engines
run against `localhost` over the **same** bundled feed — no Trufi server
involved.

Requirements: any JRE 11+ for OTP 1.5, JRE 21+ for OTP 2.x (no global
install needed — an [Adoptium](https://adoptium.net) archive extracted to
`~/.jdks/` is enough).

## OTP 1.5 (REST)

```bash
mkdir -p /tmp/otp15/graphs/default
cp apps/example/assets/routing/cochabamba.gtfs.zip /tmp/otp15/graphs/default/
curl -L -o /tmp/otp15/otp.jar \
  https://repo1.maven.org/maven2/org/opentripplanner/otp/1.5.0/otp-1.5.0-shaded.jar

java -Xmx2G -jar /tmp/otp15/otp.jar --build /tmp/otp15/graphs/default
java -Xmx2G -jar /tmp/otp15/otp.jar \
  --router default --graphs /tmp/otp15/graphs --server --port 8801
```

> **Gotcha (already fixed in the bundled feed):** OTP 1.5 dies at build
> time with `NumberFormatException: For input string: "forestgreen"` when
> `routes.txt` carries CSS color names instead of the six-hex-digit values
> the GTFS spec requires. OTP 2.x tolerates them, 1.5 does not. If you
> point it at a feed with named colors, normalize them first (any hex
> value works; the color is cosmetic).

## OTP 2.x (GraphQL)

```bash
mkdir -p /tmp/otp2
cp apps/example/assets/routing/cochabamba.gtfs.zip /tmp/otp2/
curl -L -o /tmp/otp2/otp.jar \
  "https://repo1.maven.org/maven2/org/opentripplanner/otp-shaded/2.8.1/otp-shaded-2.8.1.jar"

java -Xmx2G -jar /tmp/otp2/otp.jar --build --save /tmp/otp2
java -Xmx1G -jar /tmp/otp2/otp.jar --load /tmp/otp2 --port 8802
```

## Point the example at them

```bash
cd apps/example
flutter run \
  --dart-define=OTP15_ENDPOINT=http://10.0.2.2:8801 \
  --dart-define=OTP28_ENDPOINT=http://10.0.2.2:8802
```

`10.0.2.2` is the host loopback as seen from the Android emulator; use
`http://localhost:<port>` for desktop/web runs, or your machine's LAN IP
for a physical device.

Sanity check before blaming the app:

```bash
curl "http://localhost:8801/otp/routers/default/plan?fromPlace=-17.465,-66.14&toPlace=-17.355,-66.19&mode=TRANSIT,WALK&numItineraries=5"
```

Without a `searchWindow`/schedule caveat: the bundled Cochabamba feed is
frequency-based and runs all day, so any daytime query returns results.
