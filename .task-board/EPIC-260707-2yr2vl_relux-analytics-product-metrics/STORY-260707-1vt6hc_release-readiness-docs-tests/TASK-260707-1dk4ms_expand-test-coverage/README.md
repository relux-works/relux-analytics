# TASK-260707-1dk4ms: expand-test-coverage

## Description
Add the missing automated test coverage for the ReluxAnalytics SDK and sample-facing analytics integration behavior before the major release.

## Scope
Add focused automated tests for the new ReluxAnalytics SDK surface. Cover core value/parameter mapping, identity state, instant events, continuous event lifecycle including stale timeout, service fan-out to aggregators, Relux effect/saga routing, SwiftUI helper dispatch behavior where testable, and the sample AppMetrica adapter mapping without depending on live network delivery.

## Acceptance Criteria
- SDK tests run with swift test from sdk/ and remain green under Swift 6.2 strict concurrency settings.
- Continuous event tests cover start, update/stop merge semantics, timeout/stale close reason, interval calculation, and cleanup of active spans.
- Service tests cover start, identify, reset identity, instant event fan-out, continuous aggregate fan-out, and aggregator failure isolation expectations.
- Relux tests cover Analytics.Effect routing through Analytics.Saga into Analytics.Service.
- SwiftUI helper tests or a documented verification harness prove helpers dispatch the expected analytics effects.
- AppMetrica sample adapter mapping is covered without requiring real AppMetrica network ingestion or leaking project credentials into assertions.
- Test commands and output locations are documented in README or task outcome notes.
