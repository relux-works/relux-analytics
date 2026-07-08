# Flight Logbook

> Institutional memory. Concise, factual, high-signal.
> Newest entries first. One block per insight.

## 2026-07-09

### 1333 — AppMetrica Test Bundle Duplicate Classes
- ANOMALY: `xcodebuild` sample unit test run for `BUG-260709-21pjyu` emitted duplicate Objective-C class warnings for AppMetrica classes loaded from both `ReluxAnalyticsAppMetrica.framework` and `ReluxAnalyticsSampleTests.xctest`.
- STATUS: Non-blocking in this run; `AppMetricaServiceTests` passed 6/6 tests. Evidence in `.temp/BUG-260709-21pjyu/xcodebuild-sample-tests-01.log`.
