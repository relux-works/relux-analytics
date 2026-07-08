# TASK-260707-2xbzz0: verify-appmetrica-dashboard-ingestion

## Description
Run the sample app, emit AppMetrica events, and verify through the authenticated AppMetrica browser project that metrics reached app id 6324763.

## Scope
Use local app execution plus authenticated Safari/AppMetrica dashboard inspection to verify that sample events reach AppMetrica app id 6324763. Use no-focus browser automation and do not read/export browser secrets.

## Acceptance Criteria
- Sample app is run and emits known uniquely named or uniquely tagged events for anonymous and identified instant/continuous flows.
- AppMetrica project URL https://appmetrica.yandex.com/overview?appId=6324763&period=week&group=day&currency=rub&accuracy=medium is opened/inspected through authenticated browser session.
- Verification records whether the expected event names or event counts appear in AppMetrica, with timestamp/window and sanitized notes.
- If dashboard latency/auth/UI prevents confirmation, the task records exact blocker and local evidence that events were emitted from the app.
- No cookies, local storage, auth headers, or tokens are printed or persisted.
