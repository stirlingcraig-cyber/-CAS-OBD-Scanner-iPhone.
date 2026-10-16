# CAS OBD Scanner – iPhone app

The CAS OBD Scanner (CAS Solutions) packaged as an iPhone app with Capacitor, using the
`@capacitor-community/bluetooth-le` plugin to talk to Bluetooth LE ELM327 OBD2 adapters.

- `www/index.html` – the scanner (same as the Windows and Android versions)
- `ios/` – Xcode project (Bluetooth permission, icon, splash)
- `.github/workflows/build-iphone-app.yml` – builds an unsigned `.ipa` on GitHub's Xcode 27 runner

**Build:** Actions → *Build iPhone app* → *Run workflow*, then download the `CAS-OBD-Scanner-iPhone` artifact.
**Install:** sign and install the `.ipa` with Sideloadly on Windows (see `READ ME - iPhone.txt`).

iPhones only support **Bluetooth LE** OBD adapters (Bluetooth 4.0 / BLE / iOS); Bluetooth Classic adapters cannot connect to iOS apps.
