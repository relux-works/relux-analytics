# TASK-260707-2xbzz0 AppMetrica E2E Verification

## Local Emission Evidence

- Sample UI test passed on iPhone 17 / iOS 26.5.
- Result bundle: `.temp/ReluxAnalyticsSampleUITests-contract-03.xcresult`.
- Test log: `.temp/xcodebuild-sample-ui-tests-contract-03.log`.
- Extracted screenshots: `.temp/screenshots-relux-analytics-sample-contract-03`.
- Fresh run id: `ui-1783437986`.

The UI test exercised:

- anonymous instant event;
- anonymous continuous start/update/stop flow;
- identify sample user;
- identified instant event;
- identified continuous start/update/stop flow.

Expected AppMetrica event names:

- `sample_screen_appeared`
- `sample_anonymous_instant_tapped`
- `sample_identified_instant_tapped`
- `sample_anonymous_session_stopped`
- `sample_identified_session_stopped`
- `analytics_identified`

## Browser Verification

Inspected authenticated Safari/AppMetrica session with no-focus `mac-safari-session`.

Project:

- URL: `https://appmetrica.yandex.com/overview?appId=6324763&period=week&group=day&currency=rub&accuracy=medium`
- App id: `6324763`
- App name shown by dashboard: `sample-app`

Events report URL resolved by AppMetrica UI:

- `https://appmetrica.yandex.com/statistic?...&reportId=events...`

Checks performed:

- Today events report opened successfully.
- Week events report opened successfully.
- DOM checks searched for run id `ui-1783437986`.
- DOM checks searched for all expected event names listed above.
- Final simple check after reload returned:
  - `readyState = complete`
  - `Нет данных для выбранного периода = true`
  - `sample_anonymous_instant_tapped = false`
  - `ui-1783437986 = false`

## Result

Dashboard verification could not confirm ingestion yet. The exact blocker is AppMetrica dashboard/report availability: the authenticated Events report still shows no events for the selected period after the local sample emitted events and after a reload.

This leaves local SDK/sample behavior verified, but AppMetrica backend/dashboard visibility unconfirmed in this run.

## Sanitization

No cookies, local storage, session storage, authorization headers, or tokens were read or persisted. A temporary resource URL log containing Yandex login/user-id query parameters was sanitized in place.
