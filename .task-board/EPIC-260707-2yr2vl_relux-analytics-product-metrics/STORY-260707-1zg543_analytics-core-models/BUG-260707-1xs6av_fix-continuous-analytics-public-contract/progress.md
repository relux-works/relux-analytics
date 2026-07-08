## Status
done

## Assigned To
codex

## Created
2026-07-07T15:11:28Z

## Last Update
2026-07-08T07:52:30Z

## Blocked By
- (none)

## Blocks
- (none)

## Checklist
- [x] Attach/update analytics event contract spec before implementation
- [x] Replace public trackInstant/trackContinuous split with event-oriented track API
- [x] Keep ContinuousEventAggregate internal to manager-to-sink pipeline
- [x] Rework AppMetrica integration into ready Analytics.Service with injected ContinuousEventManager
- [x] Update sample IoC and UI metric dispatches to new API
- [x] Update and run Swift Testing coverage for SDK contract
- [x] Run sample UI test flow without browser verification
- [x] Run final AppMetrica browser E2E and record evidence or exact blocker
- [x] Self-review implementation and document findings
- [x] Document explicit service contracts in spec and bug acceptance

## Notes
Spec-first checkpoint completed: .spec/analytics-event-contract.md was added, .spec/appmetrica-sample.md was updated to remove the old Aggregator-only sample wording, and analytics-event-contract.md was attached to this bug as a precondition resource.
Implementation pass started: SDK now has Analytics.Event for public calls, Analytics.CollectorEvent for sink calls, ContinuousCommand was renamed to ContinuousEvent, and sample IoC now injects ContinuousEventManager into Analytics.AppMetricaService instead of exposing AppMetrica as an Aggregator-only dependency.
Service contract checkpoint completed: the spec now has an explicit Service Contracts section for Analytics.Service, ContinuousEventManager, Aggregator sink, and AppMetricaService. Bug acceptance now references those contracts directly.
SDK contract validation passed: swift test --package-path sdk succeeded with 8 Swift Testing tests. Source grep shows no old public trackInstant/trackContinuous/ContinuousCommand API remains outside private helper names, and ContinuousEventAggregate is only in manager/service sink flow.
Sample app validation passed with the new service contract: xcodebuild build succeeded and ReluxAnalyticsSampleUITests/testTracksAnonymousAndIdentifiedMetrics passed. Result bundle: .temp/ReluxAnalyticsSampleUITests-contract-01.xcresult. UI test log: .temp/xcodebuild-sample-ui-tests-contract-01.log. E2E run_id emitted by the app/test flow: ui-1783437545.
Service contract audit: BUG-260707-1xs6av acceptance criteria explicitly reflects the Service Contracts section from .spec/analytics-event-contract.md: Analytics.Service exposes currentIdentityState/start/identify/resetIdentity/track(Event), ContinuousEventManager is the injected aggregate source, Aggregator is only the CollectorEvent sink, and AppMetricaService is the ready product-facing Service.
UI screenshot inspection passed: latest extracted screenshots from .temp/screenshots-relux-analytics-sample-contract-01 show the sample in portrait, readable controls, anonymous/identified counters updated, continuous states idle after start/stop, and run id ui-1783437545 visible. No black screen or layout blocker found.
Self-review checkpoint: found and fixed one contract leak. ContinuousEventAggregate no longer has a public initializer; symbol graph now exposes the aggregate type and readable properties only, with no public init. Re-ran swift test --package-path sdk (8 tests passed), xcodebuild sample build (passed), and UI test on iPhone 17 / iOS 26.5 (passed). Fresh E2E run_id: ui-1783437986. Extracted and visually inspected screenshots in .temp/screenshots-relux-analytics-sample-contract-03; layout is valid.
Final browser E2E attempted: authenticated AppMetrica Events report for app id 6324763 opened via Safari automation, but after local sample run ui-1783437986 the report still showed no data and did not contain expected event names/run id. Exact dashboard/latency blocker is recorded in outcome resource BUG-260707-1xs6av_appmetrica-e2e.md.
Inline self-review reopened this bug: DefaultContinuousEventManager currently overwrites an active span on repeated .start with the same SpanID and emits no aggregate for the replaced span. This can silently drop continuous metrics; fixing manager behavior and adding Swift Testing coverage.
Inline review fix completed: repeated continuous .start with an already active SpanID now emits a replaced aggregate instead of dropping the previous span. Added Swift Testing coverage continuousManagerEmitsReplacedAggregateWhenSpanRestarts. Verification passed: swift test --package-path sdk (9 tests) and sample iOS build.
Inline reviewer verdict accepted. No remaining blocking findings after repeated-span replacement fix and aggregate initializer closure. Verification evidence: sdk tests 9/9, iOS sample build passed, UI test evidence/screenshots already recorded, board validate clean.

## Precondition Resources
- [analytics-event-contract.md](file://BUG-260707-1xs6av/analytics-event-contract.md) — Spec for public Analytics.Event API, explicit service contracts, internal continuous aggregation, service pipeline, and AppMetrica service integration.

## Outcome Resources
- [BUG-260707-1xs6av_appmetrica-e2e.md](file://BUG-260707-1xs6av/BUG-260707-1xs6av_appmetrica-e2e.md) — Final AppMetrica browser E2E evidence for continuous analytics contract bug
- [BUG-260707-1xs6av_reviewer-verdict.md](file://BUG-260707-1xs6av/BUG-260707-1xs6av_reviewer-verdict.md) — Inline reviewer acceptance verdict for analytics continuous contract fix
