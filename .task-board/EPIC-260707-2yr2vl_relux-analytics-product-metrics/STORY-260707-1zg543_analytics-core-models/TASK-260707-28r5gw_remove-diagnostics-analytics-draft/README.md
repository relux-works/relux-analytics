# TASK-260707-28r5gw: remove-diagnostics-analytics-draft

## Description
Remove the obsolete product analytics draft from Swipe2CashDiagnostics now that ReluxAnalytics owns analytics models, continuous event handling, Relux effects, SwiftUI helpers, and AppMetrica integration. Scope is limited to deleting stale diagnostics package analytics code/docs and preserving diagnostics error/logging documentation.

## Scope
(define task scope)

## Acceptance Criteria
- Swipe2CashDiagnostics no longer contains product analytics draft APIs, examples, or README sections.
- Diagnostics README still documents diagnostics, error reporting, and event logging only.
- ReluxAnalytics SDK/sample remains the reusable analytics implementation.
- No unrelated Swipe2Cash BLE/security/channel documentation is removed.
- Relevant repository builds/tests or a documented compile-scope verification are run after cleanup.
