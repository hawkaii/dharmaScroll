# dharmaScroll

A daily Gita ritual for your phone. Five tabs, one habit: a shloka feed you can
tap to go deeper on, a spoken check-in that answers with the verse that fits
your day, and a journey through the Gita that remembers where you left off.

The product blueprint lives in [`DharmaScroll_Product_Blueprint.pdf`](DharmaScroll_Product_Blueprint.pdf);
the landing page in [`dharmascroll-site.html`](dharmascroll-site.html) (open it
in a browser — it is a single self-contained file).

## Where the app is

The Flutter app is a shell: it boots, themes itself, and renders a home screen.
Everything the blueprint describes — the Shloka Feed, Mann Darpan, Checkpoint
cards, Moksh Points, Daily Sankalp, Gita Yatra, Sangha — is designed, not built.

```
lib/
├── main.dart                        entry point, one line of work
├── app.dart                         MaterialApp: theme, title, first screen
├── core/
│   └── theme/app_theme.dart         one seed colour → light and dark
└── presentation/
    └── screens/home_screen.dart     the screen being replaced
test/
└── widget_test.dart                 the app boots and renders
```

`core/` holds things nothing owns (theme, config, utils); `presentation/` holds
things the user sees. `data/` belongs beside them when models and services
arrive — not inside `presentation/`.

## Verse content

The app ships 108 Bhagavad Gita verses in `assets/data/gita_v1.json`: Sanskrit,
IAST, a short English and Hindi meaning, 3 to 5 situation tags and a
`personal_advice_ok` flag. Sources and licences are in `assets/data/CREDITS.md`.
**The meanings and tags are a draft, pending scholar review.**

The Hear feed gives 5 verses a day and walks the file in order, so nothing
repeats until all 108 have been heard. `test/verses_test.dart` checks the file.

## Sign-in (not real yet)

Onboarding offers "Continue with Google", "Continue with phone" (a code
screen) and "Continue as guest". None of it talks to a server: the app uses
`FakeAuthService` in `lib/core/auth/auth_service.dart`, which stores a local
profile in shared preferences. Google always "works" and any six-number code
"verifies". Nothing leaves the phone.

To plug in real sign-in, implement `AuthService` (Google OAuth in
`signInWithGoogle`, an SMS OTP provider in `sendCode` / `verifyCode`) and
override `authServiceProvider` in `main.dart`. The comments marked
`OAuth plugs in here` and `OTP plugs in here` show the spots.

## Practice and explainers

"Build my practice" (onboarding and You > My practice) asks five plain
questions and turns the answers into rituals through `PracticeSuggester`
(`lib/core/practice/practice.dart`). Today that is a few rules; a smarter
helper can replace it behind the same interface. Each preview shows the
first reminder the real planner (`planReminders`) would send.

The small animations in `assets/lottie/` are written by
`python3 tools/lottie_gen/gen.py` in the board v3 colours (shape layers
only: no effects, masks or expressions). With reduce motion on they hold a
still frame.

## Running it

```bash
flutter pub get
flutter run
```

## Building an APK

Every push to `main` produces one, and you never need a local Android
toolchain. `.github/workflows/build.yml` runs `flutter analyze` and
`flutter test`, builds split-per-abi release APKs, and publishes them as a
**GitHub Release** — see the [Releases page](../../releases). Each release
carries:

| File | For |
|---|---|
| `dharmascroll-<version>-arm64-v8a.apk` | most phones — start here |
| `dharmascroll-<version>-armeabi-v7a.apk` | older 32-bit phones |
| `dharmascroll-<version>-x86_64.apk` | emulators |

Pull requests run the checks but publish nothing. A second push cancels the run
in flight. Flutter is pinned in `FLUTTER_VERSION` rather than tracking `stable`,
so a release landing mid-week cannot turn a green build red without a commit.

## Before a Play Store upload

The release build is signed with the debug key and ships an APK, neither of
which Play accepts. A store submission still needs: a real upload keystore and
Play App Signing, `bundleRelease` instead of `apk`, an `applicationId` you are
happy to keep forever (currently `wiki.gradientdescent.dharmascroll`), and HTTPS
for anything the app talks to.
