# STORY-260707-1zg543: analytics-core-models

## Description
Move product analytics core mechanics from the diagnostics draft into ReluxAnalytics. This includes event value types, identity state, service protocol, instant events, continuous span commands, aggregates, and default continuous event manager.

## Scope
(define story scope)

## Acceptance Criteria
- ReluxAnalytics defines analytics values, identity state, service protocol, instant event model, continuous event commands, aggregate model, and continuous event manager.
- Continuous manager owns active span state, emits aggregates through an async sequence, and expires stale spans by timeout.
- Core models are Sendable-friendly and do not depend on diagnostics.
- Swift Testing coverage verifies instant collector parameters, manual continuous stop, stale timeout sweep, replacement close, and automatic monitor loop.
