# BUG-260707-1xs6av: fix-continuous-analytics-public-contract

## Description
Fix ReluxAnalytics public/service contract: callers send instant events and continuous start/update/end events; ContinuousEventAggregate is produced only by ContinuousEventManager and consumed internally by the service/AppMetrica bridge. AppMetrica ready solution must be a Service with an injected ContinuousEventManager, not a raw Aggregator-only surface.

## Scope
Update ReluxAnalytics SDK, AppMetrica integration, sample IoC wiring, sample metric calls, SDK tests, and sample UI tests to match the event-oriented contract in .spec/analytics-event-contract.md.

## Acceptance Criteria
Spec is attached to the bug and referenced from implementation notes. The task explicitly follows the Service Contracts section in .spec/analytics-event-contract.md. Analytics.Service exposes currentIdentityState, start, identify, resetIdentity, and track(Analytics.Event). Public callers track Analytics.Event instant or continuous start/update/stop events. ContinuousEventAggregate is created only by ContinuousEventManager and never required from UI/product code. Analytics.ContinuousEventManager is injected into services and is the only source of aggregate stream output. Analytics.Aggregator is a low-level collector sink that receives Analytics.CollectorEvent, not public continuous lifecycle events. AppMetrica ready integration is usable as an Analytics.Service with injectable ContinuousEventManager and reports manager aggregates internally. Sample emits anonymous and identified instant/continuous events through Relux effects. SDK tests and sample UI tests pass. Self-review findings are documented. Final AppMetrica browser E2E verifies emitted sample events or records an exact dashboard/latency blocker.
