# TASK-260707-2gu75e Self Review

## Findings

### Fixed: repeated continuous start dropped the previous active span

Severity: high

Files:

- `sdk/Sources/ReluxAnalytics/Core/Analytics+ContinuousEventManager.swift`
- `sdk/Tests/ReluxAnalyticsTests/AnalyticsCoreTests.swift`
- `.spec/analytics-event-contract.md`

`Analytics.DefaultContinuousEventManager.handle(.start)` overwrote `activeSpans[event.spanID]` when a second start arrived for an already active `SpanID`. The overwritten span never emitted a `ContinuousEventAggregate`, so a product flow could silently lose a continuous metric if a screen/session was restarted with a reused span id.

Fix: a repeated `.start` now emits a `.replaced` aggregate for the previous active span before storing the new span. Added `continuousManagerEmitsReplacedAggregateWhenSpanRestarts()` coverage to verify the replaced aggregate and the following completed aggregate are both emitted.

Verification:

- `swift test --package-path sdk` passed with 9 Swift Testing tests.
- `xcodebuild -workspace ReluxAnalyticsSample.xcworkspace -scheme ReluxAnalyticsSample -destination 'generic/platform=iOS Simulator' build` passed.

### Fixed: public aggregate constructor leaked collector aggregate construction

Severity: medium

Files:

- `sdk/Sources/ReluxAnalytics/Core/Analytics+ContinuousEvent.swift`
- `.spec/analytics-event-contract.md`

`Analytics.ContinuousEventAggregate` was no longer part of the public `Analytics.Service.track` contract, but it still had a public initializer. That allowed product code outside the SDK to construct collector aggregates manually, which weakened the contract that aggregates are produced only by `ContinuousEventManager`.

Fix: made the aggregate initializer internal while keeping the aggregate type and properties public for collector sinks. Updated the spec to say the aggregate is readable by sinks, but construction is not public SDK surface.

Verification:

- `swift test --package-path sdk` passed with 8 Swift Testing tests.
- `swift package dump-symbol-graph --minimum-access-level public --skip-synthesized-members` confirms `Analytics.ContinuousEventAggregate` exposes public readable properties and no public initializer.
- `xcodebuild -workspace ReluxAnalyticsSample.xcworkspace -scheme ReluxAnalyticsSample -destination 'generic/platform=iOS Simulator' build` passed.

## Checks With No Blocking Findings

- `Relux.Resolver` resolver closure only resolves `Relux`; startup analytics dispatch is in rendered content `.task`.
- Sample IoC registers `Analytics.ContinuousEventManager`, `Analytics.Service`, and `Analytics.Module` in the registry.
- Sample app imports `ReluxAnalyticsAppMetrica`, but does not import `AppMetricaCore`; direct AppMetrica SDK usage is contained in `integrations/appmetrica`.
- Public tracking surface is event-oriented: `Analytics.Effect.track(.instant(...))` and `Analytics.Effect.track(.continuous(.start/.update/.stop(...)))`.
- `Analytics.Aggregator` receives `Analytics.CollectorEvent`, not public continuous lifecycle events.
- Sample UI supports anonymous and identified instant metrics, plus anonymous and identified continuous start/update/stop flows.

## Residual Risks

- AppMetrica dashboard did not show emitted events during the verification window. This is recorded separately in `TASK-260707-2xbzz0_appmetrica-e2e.md`.
- UI tests currently duplicate accessibility identifier constants in the UI test target instead of sharing a compiled shared identifier module. This is acceptable for the sample, but a shared module would reduce drift if the UI grows.
