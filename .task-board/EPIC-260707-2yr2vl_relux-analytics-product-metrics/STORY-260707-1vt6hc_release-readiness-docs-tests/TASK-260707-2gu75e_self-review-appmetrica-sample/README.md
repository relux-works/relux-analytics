# TASK-260707-2gu75e: self-review-appmetrica-sample

## Description
Perform an inline code review of the ReluxAnalytics AppMetrica integration and sample wiring before adding UI tests and dashboard verification.

## Scope
Review the current relux-analytics sample, optional AppMetrica integration package, manifests, and skill documentation changes. Focus on architecture, Relux Resolver/IoC correctness, AppMetrica adapter boundary, Swift concurrency issues, platform/package boundaries, and test gaps.

## Acceptance Criteria
- Review findings are recorded as an outcome resource with severity and file references.
- Any blocking/obvious bugs found during review are fixed or tracked as bugs before UI tests proceed.
- Review explicitly checks that startup dispatch is not inside Relux.Resolver resolver closure.
- Review explicitly checks that AppMetrica code is outside core ReluxAnalytics and sample app does not import AppMetricaCore.
- Review explicitly checks sample supports anonymous and identified instant/continuous metric flows.
