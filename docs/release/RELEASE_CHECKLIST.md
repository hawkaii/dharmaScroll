# Release checklist: steps only the owner can do

Everything code-side is in the repo. CI builds a signed `.aab` once the four secrets below exist. Placeholders to fill first: `[DEVELOPER NAME]`, `[CONTACT EMAIL]` in `PRIVACY_POLICY.md`, `privacy.html` and `STORE_LISTING.md`.

## 1. Create the app in Play Console

You already have a Play Console account. In it: Create app, name `dharmaScroll`, default language English (India), App, Free, accept the declarations. Check which kind of account you have (Settings, Account details); step 8 depends on it.

## 2. Create the upload keystore (once, on your own computer)

```bash
keytool -genkeypair -v -keystore upload-keystore.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep `upload-keystore.jks` and its passwords in a password manager plus one offline copy. Never commit it (`*.jks` is already gitignored). With Play App Signing a lost upload key can be reset through Play support; a lost app-signing key cannot.

## 3. Add the four GitHub secrets

Run from any folder, signed in with `gh auth login`:

```bash
gh secret set ANDROID_KEYSTORE_BASE64 --repo hawkaii/dharmaScroll < <(base64 -w0 upload-keystore.jks)
gh secret set ANDROID_KEYSTORE_PASSWORD --repo hawkaii/dharmaScroll
gh secret set ANDROID_KEY_ALIAS --repo hawkaii/dharmaScroll --body upload
gh secret set ANDROID_KEY_PASSWORD --repo hawkaii/dharmaScroll
```

(On macOS use `base64 -i upload-keystore.jks`.) The two password commands prompt you, so they stay out of shell history. After this, every push to `main` attaches a signed `dharmascroll-<version>-<run>.aab` to the GitHub release. Without the secrets CI still passes, signs with the debug key, and attaches no `.aab`.

## 4. Turn on Play App Signing

In the first upload (step 6) accept "Play App Signing". Google keeps the app-signing key; your upload key only proves the upload is yours.

## 5. Publish the privacy policy

1. Repo Settings, Pages, Source: `main` branch, folder `/docs`.
2. The policy is then at `https://hawkaii.github.io/dharmaScroll/release/privacy.html`. Open it and check it loads.
3. Paste that URL in Play Console, App content, Privacy policy.

## 6. First upload (internal testing)

1. Download the `.aab` from the GitHub release.
2. Play Console, Testing, Internal testing, Create release, upload it. Add yourself as tester (a Google account email list).
3. Install from the opt-in link on a real phone. Check: the app opens, the microphone prompt appears only when you speak or chant, the icon looks right.
4. Check the merged manifest permissions: Play Console, App bundle explorer, or `apkanalyzer manifest permissions`. Expected exactly: `RECORD_AUDIO`, `POST_NOTIFICATIONS`, `VIBRATE`, `RECEIVE_BOOT_COMPLETED` (see `DATA_SAFETY.md`). If `INTERNET` or anything else shows, a plugin added it; update `DATA_SAFETY.md` and the policy or remove it.

## 7. Fill App content and the store listing

Use these files: `STORE_LISTING.md` (text, English and Hindi), `DATA_SAFETY.md`, `CONTENT_RATING.md`. Also set: target audience 18+ (not for children), Ads: No, News app: No, Government app: No, Financial features: none, Health: none.

Store graphics (upload under Main store listing):

| Asset | Size and format | In repo? |
|---|---|---|
| App icon | 512 x 512 PNG, up to 1 MB | Yes: `docs/release/store-graphics/icon-512.png` |
| Feature graphic | 1024 x 500 PNG or JPEG, no alpha | **No, make it** (emblem on `#1A0F24`, name, one line) |
| Phone screenshots | 2 to 8; PNG or JPEG, no alpha; each side 320 to 3840 px; long side at most 2x the short side | Partly: see `SCREENSHOT_PLAN.md` |
| Tablet screenshots | Optional (7-inch and 10-inch); same rules | No |

## 8. Before production: which account do you have?

Source: [Play Help: testing requirements for new personal accounts](https://support.google.com/googleplay/android-developer/answer/14151465), read for Nov 2026.

**(a) Personal account created after 13 Nov 2023.** A closed test is required first: at least **12 testers opted in continuously for 14 days**, then you apply for production access in the Console and Google reviews it (often about a week). The count and days are unchanged as of Nov 2026.
1. Testing, Closed testing, create a track, upload the same `.aab`.
2. Add 15 to 20 testers (email list or Google Group) and send them the opt-in link. Twelve is the floor; people who leave reset the count.
3. Ask them to open the app on some of those days.
4. After day 14, Dashboard, Apply for production access, answer the questions, then go to step 9.
5. Start this first, since it is the longest wait. A 20 Dec 2026 public launch needs the test to start by about 1 Dec.

**(b) Organisation account, or a personal account created on or before 13 Nov 2023.** No closed test is required. Finish internal testing (step 6), then go straight to step 9.

## 9. Production release

Production, Create release, pick the build, add release notes, send for review. Review commonly takes from a few hours to several days for a new app. Roll out at 100 percent or a staged 20 percent.

## 10. Every later release

Merge to `main`, download the new `.aab` from the GitHub release, upload to the track. `versionCode` is the CI run number, so it always rises. Change `version:` in `pubspec.yaml` (the part before `+`) for a new user-visible version.

## Policy facts checked for this repo

- Target API: Play requires API 36 or higher for new apps and updates since 31 Aug 2026 ([Play Help](https://support.google.com/googleplay/android-developer/answer/11926878)). The build file takes the higher of Flutter's default and 36.
- Application ID `wiki.gradientdescent.dharmascroll` is not `com.example.*`, so it is kept. It cannot be changed after the first upload.
- New apps must be uploaded as an App Bundle (`.aab`), not an APK.
