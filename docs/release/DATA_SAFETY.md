# Play Console: Data safety form answers

Based on the code at version 0.1.0 (shared_preferences, record, audioplayers, path_provider, flutter_svg, lottie, fl_chart; no network code, no SDK that sends data). Re-check this file whenever a feature adds a network call, a notification service, billing or an AI call.

## Data collection and security

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |
| Is all user data encrypted in transit? | Not asked when nothing is collected (nothing is transmitted). |
| Can users request that their data be deleted? | Not asked when nothing is collected. The policy says: clear storage or uninstall. |

Why "No": Play counts data as collected only when it leaves the device. Progress, settings and the voice recording stay in app storage on the phone, and no code sends them anywhere. The recording is played back on the device, not analysed or sent.

## Data types: tick none

| Category | Collected | Shared |
|---|---|---|
| Location, Personal info, Financial info, Health and fitness, Messages | No | No |
| Photos and videos, Audio (voice recordings), Files and docs | No | No |
| Calendar, Contacts, App activity, Web browsing | No | No |
| App info and performance (crash logs, diagnostics) | No | No |
| Device or other IDs | No | No |

## Other declarations

| Item | Answer |
|---|---|
| Privacy policy URL | The GitHub Pages URL of `privacy.html` (see RELEASE_CHECKLIST.md) |
| Permissions in the manifest | `RECORD_AUDIO`. Check the merged manifest for any a plugin adds (checklist step). |
| Ads | No ads |
| Target audience | 18 and over, or 13 and over. Not designed for children. Do not join the Families programme. |
| Account creation | None, so no account-deletion URL is needed |
| Financial features, health app, government app, news app | No to all |
| App access | Everything works without login; no review credentials needed |

## When this changes

Answer "Yes, collected" and redo the form if any of these arrive: reminders through a push service, a login, billing (Play Billing makes purchase history collected data), Ekant or any AI call that sends text off the phone, crash reporting, or analytics.
