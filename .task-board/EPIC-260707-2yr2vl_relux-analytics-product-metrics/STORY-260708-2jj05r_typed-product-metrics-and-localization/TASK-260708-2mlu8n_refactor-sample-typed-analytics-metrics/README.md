# TASK-260708-2mlu8n: refactor-sample-typed-analytics-metrics

## Description
Refactor the ReluxAnalytics sample app so sample UI/content code uses typed product metric definitions instead of inline Analytics.InstantEvent and Analytics.ContinuousEvent construction.

## Scope
(define task scope)

## Acceptance Criteria
- Add a typed sample metrics namespace/tree that reflects sample screens and controls.
- Move metric names, span ids, finish event names, timeout values, and stable parameters into that typed layer.
- Keep UI actions readable and domain-oriented.
- Preserve AppMetrica service wiring and Relux startup ordering.
- Run SDK tests and sample build/UI tests that cover the sample metrics flow.
