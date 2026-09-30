# Release guide

## Versioning
`pubspec.yaml` → `version: 1.0.0+1` (`name+buildNumber`). Bump the build number
on every store upload.

## API keys (optional)
Remote photo download is off unless a key is compiled in:

```sh
flutter build appbundle --release \
  --dart-define=UNSPLASH_KEY=your_access_key \
  --dart-define=PEXELS_KEY=your_pexels_key
```

Keys never ship in source; `ApiKeys` reads them via `String.fromEnvironment`.
Without keys the Automation screen shows a notice and rotation uses the bundled
gallery only.

## AI providers (optional)
The Bible AI tab falls back to local search only unless at least one provider
key is compiled in. Providers are tried in order (Grok → Gemini → OpenAI) and
automatically fall through to the next on a rate limit, quota, or error.

1. `cp secrets.example.json secrets.json` (git-ignored) and fill in the keys
   you have — one is enough.
2. Run/build with `--dart-define-from-file=secrets.json`, e.g.:
   ```sh
   flutter run --dart-define-from-file=secrets.json
   flutter build apk --release --dart-define-from-file=secrets.json
   ```

`AiApiKeys` reads the keys via `String.fromEnvironment`; see
`lib/features/ai/data/ai_client.dart`.

## Icons & splash
Regenerate artwork and platform assets:

```sh
python3 tools/gen_icon.py
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Android
1. Create an upload keystore once:
   `keytool -genkey -v -keystore ~/versebible-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. `cp android/key.properties.example android/key.properties` and fill it in
   (git-ignored). Without it the release build signs with the debug key.
3. Build:
   ```sh
   flutter build appbundle --release            # Play Store
   flutter build apk --release --split-per-abi  # side-load / BlueStacks (x86_64)
   ```
   R8 minification + resource shrinking are on; see `android/app/proguard-rules.pro`.

## iOS
1. `open ios/Runner.xcworkspace`, set Team + bundle id `com.versewall.bible`.
2. Add the **VerseWidget** extension target (see `ios/VerseWidget/README.md`)
   and the App Group `group.com.versewall.bible` to both targets.
3. `flutter build ipa --release` (add the `--dart-define` flags above).

## Store checklist
- Privacy policy: `PRIVACY_POLICY.md` (host it and link in both consoles).
- Data safety (Play) / App Privacy (App Store): **no data collected**;
  optional network only for photo download.
- Screenshots: Reader, Wallpaper gallery, Preview, Automation, Widget.
- Content rating: Everyone / 4+.

## Smoke test before upload
```sh
flutter analyze
flutter test
```
Then on a device / BlueStacks:
1. Wallpaper → Automation → enable, interval **Hourly**, **Refresh now** →
   lock screen changes, History gets a row.
2. Leave the device idle ≥ 1 h → a second History row appears (trigger `auto`).
3. Add the "Verse of the Day" home-screen widget → shows current verse.
