# TASK-260707-1dk4ms outcome

Implemented coverage and verification for the ReluxAnalytics AppMetrica sample path.

Changes:
- Added injectable internal AppMetrica client for ReluxAnalyticsAppMetrica unit tests without live network dependency.
- Added AppMetrica events-buffer flush policy. Production default is automatic buffered delivery; the sample uses afterEveryReport for deterministic demo and e2e verification.
- Added sample unit tests for activation idempotency, identity forwarding, instant event mapping, continuous aggregate mapping, and configured events-buffer flush.
- Kept sample product metrics typed under ReluxAnalyticsSample.Metrics so views dispatch named domain metrics instead of building raw payloads inline.

Validation:
- `swift test --package-path sdk` passed: `.temp/swift-test-sdk-flush-policy-01.log` with 9 Swift Testing tests.
- Sample unit tests passed: `.temp/xcodebuild-sample-unit-tests-flush-policy-01.log` with 4 Swift Testing tests.
- Sample build passed: `.temp/xcodebuild-sample-build-flush-policy-01.log`.
- Sample UI test passed: `.temp/xcodebuild-sample-ui-tests-flush-policy-01.log`, result `.temp/ReluxAnalyticsSampleMetricsUITests-ui-metrics-flush-1783500585.xcresult`.
- Screenshots extracted to `.temp/screenshots/metrics-flush-01` and visually inspected.
- AppMetrica browser Events report was checked on 2026-07-08 for app 6324763. It showed 39 total events for the selected week and 32 events on July 8 after the sample UI run.

Caveat:
- Direct `swift test --package-path integrations/appmetrica` is not used as release evidence because the AppMetrica SwiftPM dependency graph trips on an upstream platform mismatch for the host test build. The AppMetrica mapping is verified through the generated Tuist iOS sample unit-test target instead.
