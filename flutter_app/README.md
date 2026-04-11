# Training Logger

A cross-platform climbing/strength training logger built with Flutter.  
Works on **Android**, **iOS**, and **Web** (desktop browser) from a single codebase.

---

## Prerequisites

Install the Flutter SDK if you haven't already:

```bash
git clone https://github.com/flutter/flutter.git ~/sdk/flutter
echo 'export PATH="$PATH:$HOME/sdk/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
flutter doctor          # check for missing dependencies
```

Then fetch dependencies for this project:

```bash
cd flutter_app
flutter pub get
```

---

## Running on Android (phone)

### Quick run via USB

1. Enable **Developer options** on your phone: Settings → About phone → tap *Build number* 7 times.
2. Enable **USB debugging** inside Developer options.
3. Connect via USB and accept the prompt on your phone.
4. Run:

```bash
flutter devices          # confirm your phone is listed
flutter run              # builds debug APK and installs it
```

Hot reload is available while running (`r` in the terminal, `R` for full restart).

### Install a release APK (no USB needed after this)

```bash
flutter build apk --release
```

The APK is at `build/app/outputs/flutter-apk/app-release.apk`.

Transfer it to your phone (email, USB, cloud storage) and open it to install.  
You may need to allow *Install from unknown sources* in your phone's security settings.

---

## Running on iOS

Requires a Mac with Xcode installed.

```bash
flutter devices          # find your device/simulator ID
flutter run -d <device>
```

For a release build:

```bash
flutter build ios --release
```

Distributing outside the App Store requires an Apple Developer account.

---

## Running the web / desktop version (browser)

Start a local development server:

```bash
flutter run -d web-server --web-port 8080
```

Open `http://localhost:8080` in any browser (Firefox, LibreWolf, Chrome, etc.).

> **Note:** The app uses WebAssembly SQLite which requires specific HTTP headers.
> The Flutter dev server sets these automatically. If you deploy to a static host
> (nginx, GitHub Pages, etc.) you must add:
>
> ```
> Cross-Origin-Opener-Policy: same-origin
> Cross-Origin-Embedder-Policy: require-corp
> ```

### Static release build

```bash
flutter build web --release
```

Serve the `build/web/` directory from any static host.

---

## Transferring data between phone and desktop

### Export

1. Open the **Exercises** tab.
2. Tap **⋮** (top-right) → **Export backup**.
   - **Android/iOS:** OS share sheet opens — choose email, cloud storage, AirDrop, etc.
   - **Browser:** a `.json` file downloads automatically.

### Import

1. Move the `.json` file to the target device.
2. Open the **Exercises** tab → **⋮** → **Import backup**.
3. Pick the file. A snackbar confirms how many sets were imported.

Re-importing the same file is safe — duplicates are skipped automatically (matched by timestamp).

### Importing from FitNotes

1. FitNotes: **Settings → Backup & Restore → Export as CSV**.
2. Training Logger: **Exercises ⋮ → Import FitNotes CSV**.
3. Review the preview, then tap **Import**.

---

## Rebuilding the web SQLite worker (rarely needed)

`web/drift_worker.js` is pre-compiled and committed. Only rebuild if you upgrade
the `drift` package to a new major version:

```bash
dart compile js -O2 -o web/drift_worker.js lib/drift_worker.dart
```
