# StreamVault Roku

Dev-first Roku SceneGraph sideload app for StreamVault.

This package does not bundle channels, playlists, credentials, or media. Configure a Cloudflare Worker URL on-device, then load a catalog endpoint or play a direct HLS URL.

## App Flow

- Provider Settings: enter the Worker base URL, catalog path, and optional direct HLS URL.
- Channel List: fetches channels from the configured Worker URL and catalog path.
- Video Player: launches Roku's native `Video` node for HLS or directly playable URLs.

## Expected Catalog Shape

The channel loader accepts any of these JSON shapes:

```json
[
  { "name": "Example", "url": "https://example.com/live.m3u8" }
]
```

```json
{
  "channels": [
    { "title": "Example", "streamUrl": "https://example.com/live.m3u8" }
  ]
}
```

It also checks `items`, `content`, and `data` arrays, and common URL fields such as `url`, `stream_url`, `streamUrl`, `playbackUrl`, `hls`, and `src`.

For the existing Cloudflare Worker catalog, a practical starting path is:

```text
/api/catalog/content?connectionId=dev&type=live
```

## Build Zip

From `StreamVault/roku`:

```powershell
.\scripts\package.ps1
```

The sideload zip is written to `roku/dist/streamvault-roku.zip`.

## Sideload

1. Enable Developer Mode on the Roku device.
2. Open the Roku Developer Application Installer in a browser.
3. Upload `dist/streamvault-roku.zip`.

## Notes

- Settings are stored in the Roku registry section `StreamVault`.
- The Worker URL is normalized by trimming trailing slashes.
- The catalog path can be either a relative path such as `/api/catalog/content?connectionId=dev&type=live` or a full URL.
- If streams are HTTP-only or provider-bound, route them through the Worker `/stream?url=...` endpoint before saving them in catalog data.
