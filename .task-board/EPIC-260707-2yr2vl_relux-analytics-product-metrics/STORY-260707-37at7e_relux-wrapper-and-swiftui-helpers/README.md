# STORY-260707-37at7e: relux-wrapper-and-swiftui-helpers

## Description
Add Relux-facing analytics APIs: effects, saga/flow handler, module composition, and SwiftUI View helpers so feature modules can emit metrics from UI and flow code without direct SDK calls.

## Scope
(define story scope)

## Acceptance Criteria
- ReluxAnalytics exposes Effect cases for start, identify, reset identity, instant event, and continuous event commands.
- ReluxAnalytics exposes a Saga or Flow actor that routes effects to an injected Analytics.Service and ContinuousEventManager.
- ReluxAnalytics.Module registers the analytics saga with no fake product state.
- SwiftUI helpers dispatch analytics effects using existing Relux async dispatch conventions.
- Tests cover effect routing with spy service and continuous aggregate forwarding.
