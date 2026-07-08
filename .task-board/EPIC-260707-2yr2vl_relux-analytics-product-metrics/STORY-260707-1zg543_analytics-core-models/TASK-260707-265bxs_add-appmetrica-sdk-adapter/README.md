# TASK-260707-265bxs: add-appmetrica-sdk-adapter

## Description
Add an optional ReluxAnalytics SDK adapter target that implements Analytics.Aggregator on top of AppMetricaCore so apps can use AppMetrica without writing their own adapter.

## Scope
Add an optional SwiftPM product/target for AppMetrica integration while keeping the core ReluxAnalytics product vendor-neutral. The integration target may depend on AppMetricaCore and ReluxAnalytics, but ReluxAnalytics itself must not import AppMetricaCore.

## Acceptance Criteria
- sdk/Package.swift exposes core product ReluxAnalytics and optional product ReluxAnalyticsAppMetrica.
- ReluxAnalytics core target remains free of AppMetricaCore imports and package dependency usage.
- ReluxAnalyticsAppMetrica target depends on ReluxAnalytics and AppMetricaCore.
- Integration exposes a public type that accepts an AppMetrica API key in its initializer and conforms to Analytics.Aggregator.
- Integration starts AppMetrica, identifies user profile id, tracks instant events, and tracks continuous aggregate finish events.
- Integration maps Analytics.Value string/int/double/bool parameters to AppMetrica parameters.
- Sample app consumes ReluxAnalyticsAppMetrica through IoC instead of defining an app-local AppMetrica adapter.
- SDK tests still pass for core target, and sample build passes with the optional integration target linked.
