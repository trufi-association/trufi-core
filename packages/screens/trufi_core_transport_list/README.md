# trufi_core_transport_list

Routes list, route detail, and the operator QR sheet.

## Host-app requirements

### Operator QR codes

Pass `shareBaseUrl` to `TransportListTrufiScreen` with the app's **https**
base (e.g. `https://planner.trufi.app`). The QR encodes
`<base>/routes?operator=<agency>`.

A QR is read by a camera app, which resolves http(s) and nothing else — a
custom scheme such as `trufiapp://` produces a code that opens nothing, so
without a usable https base the QR affordances stay hidden by design.

For the scanned link to open the **app** (rather than the website) the host
app must register it as an App Link / Universal Link: an intent filter for
that host with `android:autoVerify="true"`, plus a matching
`assetlinks.json` (Android) and `apple-app-site-association` (iOS) served
from the domain. On Android the verification uses the **signing key the
store re-signs with**, so App Links only resolve on store-installed builds
— a locally built APK opens the browser instead. Without any of this the
link still works: it falls back to the web app.

### Copying the QR image

"Copy QR" hands a rendered PNG to the clipboard through the `pasteboard`
plugin, which needs a `FileProvider` in the **host app's** manifest:

```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.provider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths" />
</provider>
```

with `android/app/src/main/res/xml/provider_paths.xml`:

```xml
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <cache-path name="cache" path="." />
</paths>
```

`cache-path` is the root that matters — the plugin writes the PNG to the
app's internal cache. (The plugin's own README documents only
`external-path`, which leaves copying failing with *"Failed to find
configured root that contains /data/data/&lt;pkg&gt;/cache/…"*.)
