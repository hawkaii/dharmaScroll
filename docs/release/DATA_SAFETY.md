# Play Console: Data safety form answers

Based on the code at version 0.2.0 (shared_preferences, flutter_secure_storage, record, speech_to_text, audioplayers, path_provider, flutter_local_notifications, timezone, share_plus, url_launcher, flutter_svg, lottie, fl_chart). There is no network code and no SDK that sends data, and the release manifest has no `INTERNET` permission. Re-check this file whenever a feature adds a network call, a push service, billing or an AI call.

## Data collection and security

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |
| Is all user data encrypted in transit? | Not asked when nothing is collected (nothing is transmitted). |
| Can users request that their data be deleted? | Not asked when nothing is collected. The policy says: clear storage or uninstall. |

Why "No": Play counts data as collected only when it leaves the device. Progress, settings, city and rituals, the Sankalp, kept Ekant notes and the voice recording stay in app storage on the phone, and no code sends them anywhere. Without `INTERNET` the app cannot send them.

Speech to text runs in the phone's own speech service (Google's on most phones), a system component, not an SDK inside the app. Ekant asks it to stay on the device (`onDevice: true`). Mann Darpan does not, so the system service may use its own servers. The privacy policy says so. If Play review disagrees, tick Audio > Voice or sound recordings as collected, processed ephemerally, not shared, for App functionality.

Share cards go out only through the Android share sheet when the user taps Share. Play does not count user-initiated sharing as data sharing.

## Data types: tick none

| Category | Collected | Shared |
|---|---|---|
| Location, Personal info, Financial info, Health and fitness, Messages | No | No |
| Photos and videos, Audio (voice recordings), Files and docs | No | No |
| Calendar, Contacts, App activity, Web browsing | No | No |
| App info and performance (crash logs, diagnostics) | No | No |
| Device or other IDs | No | No |

City is picked from a bundled list and never leaves the phone, so it is not Location data.

## Permissions in the merged release manifest

| Permission | From | Used for |
|---|---|---|
| `RECORD_AUDIO` | app manifest, `record` | Mann Darpan, Ekant and chanting: speech to text and the on-device voice note |
| `POST_NOTIFICATIONS` | `flutter_local_notifications` | Ritual and daily reminders, asked when a ritual is switched on |
| `VIBRATE` | `flutter_local_notifications` | Reminder notifications |
| `RECEIVE_BOOT_COMPLETED` | app manifest | The plugin's boot receiver puts scheduled reminders back after a restart |

Not requested: `INTERNET` (debug and profile builds only), `CALL_PHONE`, `SEND_SMS`, `SCHEDULE_EXACT_ALARM` (reminders are inexact), location, contacts, storage.

Package queries (no permission, needed on Android 11+ so the app can see these apps): `android.speech.RecognitionService` (speech to text), `DIAL` with `tel:` and `SENDTO` with `sms:` (the crisis screen opens the dialler or messages app with Tele-MANAS 14416, 112 or a text to someone you trust filled in; the user presses call or send), and Flutter's default `PROCESS_TEXT`.

## Other declarations

| Item | Answer |
|---|---|
| Privacy policy URL | The GitHub Pages URL of `privacy.html` (see RELEASE_CHECKLIST.md) |
| Ads | No ads |
| Target audience | 18 and over, or 13 and over. Not designed for children. Do not join the Families programme. |
| Account creation | None, so no account-deletion URL is needed |
| Financial features, health app, government app, news app | No to all |
| App access | Everything works without login; no review credentials needed |

## When this changes

Answer "Yes, collected" and redo the form if any of these arrive: reminders through a push service, a login, billing (Play Billing makes purchase history collected data), Ekant or any AI call that sends text off the phone, crash reporting, or analytics.
