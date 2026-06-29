# StreamVault webOS Package

Dev-first LG webOS web app shell for sideloading the built StreamVault React app.

## Build The Web App

From `streamvault/`:

```bash
npm install
npm run build:tv
```

That builds `streamvault/dist` and copies it into `platforms/webos/www/dist`.

To sync only this package after an existing build:

```bash
cd streamvault
npm run tv:webos:sync
```

## Package And Install With webOS CLI

From `platforms/webos/`:

```bash
ares-package .
ares-install --device <device-name> com.streamvault.tv_1.0.0_all.ipk
ares-launch --device <device-name> com.streamvault.tv
```

Use `ares-setup-device` first if your TV or emulator is not registered yet.

## Notes

- `www/dist` is generated and intentionally not tracked.
- `icon.png` and `largeIcon.png` are placeholders. Replace them with final production TV artwork before store submission.
- The package loads `www/dist/index.html`, so run the sync command after every frontend build.
