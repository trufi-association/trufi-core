# trufi_core_transport_list

Transport list screen for Trufi apps — displays routes, route details, and
per-operator shareable QR codes.

## Host-app setup for the operator QR dialog

### Android: FileProvider (required for "Copy QR")

The "Copy QR" button copies the QR **image** via the `pasteboard` plugin.
On Android the plugin writes the PNG to `context.cacheDir` and exposes it
through a `FileProvider` with authority `${applicationId}.provider` — which
**the host app must declare**, or copying fails at runtime with a
`PlatformException` (surfaced in the dialog as "Couldn't copy the QR").

Add to `android/app/src/main/AndroidManifest.xml` inside `<application>`:

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

And create `android/app/src/main/res/xml/provider_paths.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <cache-path name="cache" path="." />
    <external-path name="external_files" path="." />
</paths>
```

Note: the pasteboard README only shows `external-path`, but the plugin
writes to the cache directory — **`cache-path` is the entry that matters**.

### Shareable links: prefer an https `shareBaseUrl`

Pass `TransportListTrufiScreen(shareBaseUrl: 'https://your.domain')` so QR
codes and shared links use `https://your.domain/routes?operator=X`. Camera
apps open https QR codes and messengers linkify them; the custom-scheme
fallback (`yourscheme://routes?...`) does neither, and additionally requires
a matching intent-filter (`android:host="routes"`) in the host manifest.
