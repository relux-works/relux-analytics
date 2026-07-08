## Status
closed

## Assigned To
codex

## Created
2026-07-07T14:42:19Z

## Last Update
2026-07-08T07:53:14Z

## Blocked By
- (none)

## Blocks
- (none)

## Checklist
- [x] Add optional ReluxAnalyticsAppMetrica SwiftPM product and target
- [x] Implement public AppMetrica integration conforming to Analytics.Aggregator
- [x] Move sample AppMetrica wiring from app-local adapter to SDK integration target
- [x] Verify SDK tests and sample iOS build

## Notes
Implementation constraint: adding AppMetrica package directly to sdk/Package.swift breaks macOS swift test planning because upstream AppMetricaCrashes declares macOS 10.13 while KSCrash Recording requires macOS 10.14. Keep core sdk/Package.swift vendor-neutral and put ReluxAnalyticsAppMetrica into integrations/appmetrica as an iOS-only Swift package/product depending on ../sdk and AppMetricaCore.
Reviewer closure: task AC is superseded by BUG-260707-1xs6av service contract. Current accepted design keeps core SDK vendor-neutral, ships ReluxAnalyticsAppMetrica as an iOS integration package, but exposes Analytics.AppMetricaService rather than a public AppMetrica Analytics.Aggregator. Private AppMetricaAggregator remains an implementation detail behind the service.

## Precondition Resources
(none)

## Outcome Resources
- [TASK-260707-265bxs_outcome.md](file://TASK-260707-265bxs/TASK-260707-265bxs_outcome.md) — AppMetrica integration package implementation and verification
