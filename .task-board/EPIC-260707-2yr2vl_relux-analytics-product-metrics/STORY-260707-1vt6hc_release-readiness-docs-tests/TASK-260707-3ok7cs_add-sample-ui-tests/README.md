# TASK-260707-3ok7cs: add-sample-ui-tests

## Description
Add UI tests for the ReluxAnalytics sample using the iOS UI testing tooling pattern, including screenshot evidence and anonymous/identified analytics event flows.

## Scope
Add iOS UI tests for the generated Tuist sample app. Tests must use accessible UI identifiers/Page Object shape where practical, run on iOS Simulator, capture screenshots, extract screenshots into .temp/, and visually verify them. The exercised flow must send anonymous and identified instant metrics plus anonymous and identified continuous start/stop metrics.

## Acceptance Criteria
- Sample UI exposes stable accessibility identifiers for all analytics controls and status labels.
- UI tests launch ReluxAnalyticsSample and wait for the rendered content after Relux.Resolver resolves.
- UI tests exercise reset identity/an anonymous instant event/an anonymous continuous start-stop/identify/an identified instant event/an identified continuous start-stop.
- UI tests capture screenshots for initial screen and after key actions.
- Screenshots are extracted to .temp/ and visually inspected.
- xcodebuild test succeeds for the UI test target or any blocker is documented with exact evidence.
