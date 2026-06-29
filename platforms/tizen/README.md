# StreamVault Tizen Package

Dev-first Samsung Tizen web app shell for sideloading the built StreamVault React app.

## Build The Web App

From `streamvault/`:

```bash
npm install
npm run build:tv
```

That builds `streamvault/dist` and copies it into `platforms/tizen/www/dist`.

To sync only this package after an existing build:

```bash
cd streamvault
npm run tv:tizen:sync
```

## Package And Install With Tizen Studio CLI

From `platforms/tizen/`:

```bash
tizen package -t wgt -o out -- .
tizen install -n out/StreamVault.wgt -t <device-or-emulator-name>
```

If your Tizen profile requires signing, add the profile argument your local SDK uses, for example:

```bash
tizen package -t wgt -s <security-profile-name> -o out -- .
```

## Notes

- `www/dist` is generated and intentionally not tracked.
- `www/icon.png` is a placeholder. Replace it with final production TV artwork before store submission.
- The package loads `www/dist/index.html`, so run the sync command after every frontend build.
