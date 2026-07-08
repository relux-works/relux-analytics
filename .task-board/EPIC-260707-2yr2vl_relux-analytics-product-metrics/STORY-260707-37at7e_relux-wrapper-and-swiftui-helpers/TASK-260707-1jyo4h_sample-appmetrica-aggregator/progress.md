## Status
closed

## Assigned To
codex

## Created
2026-07-07T14:16:35Z

## Last Update
2026-07-08T07:53:14Z

## Blocked By
- (none)

## Blocks
- (none)

## Checklist
- [x] Use ios-app-manager scaffold commands for SwiftIoC and Relux setup where supported
- [x] Move sample Relux construction into app-local Registry/IoC builders instead of building it directly in App.body
- [x] Register Analytics.Module through the Relux builder and resolve Analytics.Service/AppMetrica aggregator through IoC
- [x] Keep Relux.Resolver as the async wait gate and render the root view below resolved Relux
- [x] Run package resolve, Tuist generate, xcodebuild sample build, and attach verification notes
- [x] Do not dispatch startup actions inside Relux.Resolver resolver closure; move startup dispatch below Resolver into rendered content/task

## Notes
Scaffold/tooling observation: dep add-external linked AppMetricaCore into Project.swift, but Package.swift targetSettings did not include the requested AppMetricaCore OTHER_LDFLAGS entry. Sample requires a scoped manifest patch for -ObjC unless ios-app-manager is fixed.
Review feedback: current sample App.swift builds but uses an ad hoc Relux setup. Rework sample to match Swipe2Cash demo pattern: scaffold-managed SwiftIoC dependency, app-local registry/composition root, Relux resolved through IoC, modules registered in the Relux builder, and SwiftUI root rendered below Relux.Resolver.
Review feedback: resolver closure must only resolve and return Relux. Dispatching startup actions there can miss SwiftUI EnvironmentObject wiring because Relux.Resolver has not yet rendered content(relux).relux(relux).passingObservableToEnvironment(fromStore:).
Reviewer closure: task AC is superseded by the newer service-oriented sample contract from BUG-260707-1xs6av. Sample no longer wires an app-local AppMetrica aggregator; it resolves Analytics.AppMetricaService through IoC and dispatches Analytics.Effect.track(Event) from rendered content.

## Precondition Resources
- [appmetrica-sample.md](file://TASK-260707-1jyo4h/appmetrica-sample.md) — AppMetrica sample project key, project URL, docs URL, and integration decision

## Outcome Resources
- [TASK-260707-1jyo4h_sample-appmetrica-aggregator-outcome.md](file://TASK-260707-1jyo4h/TASK-260707-1jyo4h_sample-appmetrica-aggregator-outcome.md) — Sample AppMetrica aggregator implementation and verification notes
- [TASK-260707-1jyo4h_ioc-sample-outcome.md](file://TASK-260707-1jyo4h/TASK-260707-1jyo4h_ioc-sample-outcome.md) — IoC/Relux sample rework and verification
