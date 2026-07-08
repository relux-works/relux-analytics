# BUG-260709-21pjyu: appmetrica-reports-after-activation-failure

## Description
Fix ReluxAnalytics AppMetrica aggregator activation handling. The aggregator stores the boolean result of AppMetrica activation, but identify and track currently continue to set identity/report events even if activation returned false. This can send calls through an inactive or misconfigured AppMetrica client and hides activation failure semantics from tests.

## Scope
ReluxAnalytics AppMetrica integration and its tests only. Do not change public analytics event models unless required for the fix. Do not commit, push, tag, or rewrite history in this worker run.

## Acceptance Criteria
If AppMetrica activation fails, identify and track do not call AppMetrica reportEvent, setUserProfileID, or sendEventsBuffer for that failed activation state. Activation remains idempotent and successful activation behavior is unchanged. Tests cover activation failure and successful activation paths. The package test suite or the targeted ReluxAnalytics tests pass locally.
