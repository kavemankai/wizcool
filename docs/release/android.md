# Android Release Guide — Fringe Ledger

> Everything needed to go from this repo to a Play-Store-ready build.
> Steps marked **[YOU]** are manual one-time setup that only a human can do
> (installs, accounts, secrets). Everything else is repeatable.

## 1. One-time machine setup **[YOU]**

1. **Install JDK 17** (Temurin): https://adoptium.net/temurin/releases/?version=17
   — pick the Windows x64 `.msi`, default options.
2. **Install Android Studio** (easiest way to get the SDK):
   https://developer.android.com/studio — run it once, let it install the
   default SDK. Note the SDK path (usually
   `C:\Users\kyler\AppData\Local\Android\Sdk`).
3. **Install Godot export templates**: in the Godot editor →
   `Editor > Manage Export Templates… > Download and Install` (must match
   4.6.2 exactly).
4. **Point Godot at the SDK/JDK**: `Editor > Editor Settings > Export > Android`
   - `Java SDK Path` → the JDK 17 folder
   - `Android SDK Path` → the SDK folder from step 2
5. Open `Project > Export…` once — Godot will validate both presets and
   normalise any keys in `export_presets.cfg`.

## 2. Debug build on your phone

1. Enable **Developer options + USB debugging** on the phone, plug it in.
2. In Godot: `Project > Export… > Android Debug APK > Export Project`
   (or just press the **remote deploy** button in the editor toolbar with
   the phone connected — one-click install & run).
3. CLI alternative once templates/SDK are set:
   ```
   godot --headless --export-debug "Android Debug APK" build/fringe-ledger-debug.apk
   adb install -r build/fringe-ledger-debug.apk
   ```

## 3. Upload keystore **[YOU — keep it safe forever]**

The Play Store release must be signed with a keystore you keep. Create once:

```
keytool -genkeypair -v -keystore fringe-ledger-upload.keystore ^
  -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

- Store the file **outside the repo** (e.g. `C:\Users\kyler\keystores\`) and
  back it up. Never commit it.
- In Godot `Editor Settings > Export > Android`, or per-preset under
  `Keystore`, set: release keystore path, alias `upload`, and the password.
  (Do not write the password into any repo file.)

## 4. Release build (AAB)

1. The **Android Release AAB** preset uses a Gradle build (first run
   downloads Gradle — needs network, takes a few minutes).
2. `Project > Export… > Android Release AAB > Export Project` →
   `build/fringe-ledger-release.aab`.
3. Every store upload needs `version/code` bumped (+1) in both presets and
   `config/version` in project.godot kept in sync.

## 5. Play Console **[YOU]**

1. Enrol at https://play.google.com/console ($25 one-time).
2. Create app → **Fringe Ledger** → Game → Premium/Free.
3. Upload the AAB to **Internal testing** first; install via the testing
   link on your phone; then promote to Production.
4. Store listing requirements (assets live in `docs/release/store/` once
   the art phase produces them):
   - App icon 512×512 PNG
   - Feature graphic 1024×500 PNG
   - ≥2 phone screenshots (1280×720 landscape works)
   - Short description (≤80 chars) + full description (≤4000 chars)
   - Privacy policy URL (the game collects no data — host the text from
     `docs/release/privacy-policy.md` anywhere public, e.g. a GitHub page)
   - Content rating questionnaire (violence: mild/fantasy; no
     gambling/ads/user content/data collection)

## 6. What is already configured in this repo

- `project.godot`: gl_compatibility renderer (desktop + mobile),
  sensor-landscape orientation, version 1.0.0, ETC2/ASTC import.
- `export_presets.cfg`: Debug APK (arm64) + Release AAB (Gradle, arm64),
  package `com.kavemankai.fringeledger`, immersive mode on, backups off.
- App shell: title/settings/pause, Android back button handling, quit
  confirm, settings persistence.
- Save path `user://` — survives app updates; removed on uninstall
  (user_data_backup deliberately off).

## 7. Pre-upload checklist

- [ ] Adaptive icons set in both presets (432×432 fg/bg — art phase)
- [ ] Boot splash set (`application/boot_splash/image` — art phase)
- [ ] version/code bumped if re-uploading
- [ ] Full mission playthrough on device (touch, audio, suspend/resume,
      back button, save persists after force-close)
- [ ] AAB signed with the upload keystore (not debug keys)
