## Outcome

Refactored the sample app analytics call sites to use a typed product metrics tree.

Changed files:

- `sample/Targets/ReluxAnalyticsSample/Sources/App/ReluxAnalyticsSample.Metrics.swift`
- `sample/Targets/ReluxAnalyticsSample/Sources/App/ReluxAnalyticsSample.Content.swift`

Key points:

- Added `ReluxAnalyticsSample.Metrics` as the sample-local metric namespace.
- Moved event names, identity reasons, span ids, finish event names, timeout values, and stable parameter keys into the metrics tree.
- Kept SwiftUI actions domain-oriented: content now tracks typed events returned by `Metrics.Main` and identifies through `Metrics.Identity`.
- Preserved the existing AppMetrica service wiring, IoC-driven Relux startup, and rendered-content startup dispatch ordering.
- Regenerated the Tuist project so `ReluxAnalyticsSample.Metrics.swift` is included in the sample target.

Validation:

- `swift test --package-path sdk`
  - Log: `.temp/swift-test-sdk-metrics-refactor-02.log`
  - Result: 9 Swift Testing tests passed.
- `xcodebuild -workspace ReluxAnalyticsSample.xcworkspace -scheme ReluxAnalyticsSample -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData build`
  - Log: `.temp/xcodebuild-sample-metrics-refactor-03.log`
  - Result: build succeeded.
- `xcodebuild ... test` on iPhone 17 Pro simulator
  - Log: `.temp/xcodebuild-sample-ui-metrics-refactor-01.log`
  - Result: 1 UI test passed, 0 failures.
  - Result bundle: `.temp/ReluxAnalyticsSampleMetricsUITests-ui-metrics-1783498878.xcresult`
  - Test run id printed by the app: `ui-1783498912`
- Extracted and visually inspected screenshots:
  - `.temp/screenshots/metrics-refactor-01/Run_2026-07-08_11-21-52/Test_testTracksAnonymousAndIdentifiedMetrics/Step_01__11-21-58-430__sample_ready.png`
  - `.temp/screenshots/metrics-refactor-01/Run_2026-07-08_11-21-52/Test_testTracksAnonymousAndIdentifiedMetrics/Step_02__11-22-04-737__anonymous_metrics_tracked.png`
  - `.temp/screenshots/metrics-refactor-01/Run_2026-07-08_11-21-52/Test_testTracksAnonymousAndIdentifiedMetrics/Step_03__11-22-10-917__identified_metrics_tracked.png`

Self-review:

- The sample UI no longer builds raw analytics payloads inline.
- Anonymous and identified instant events are both exercised.
- Anonymous and identified continuous start/update/stop flows are both exercised through the existing UI test.
- Identity reset and identify paths remain explicit at the call site.
- No unrelated product behavior was changed.
