# EPIC-260707-2yr2vl: relux-analytics-product-metrics

## Description
Build a reusable ReluxAnalytics Swift package for product metrics collection. The package owns analytics event models, instant and continuous event handling, service abstraction, Relux effects/saga/module, and SwiftUI helpers. Host applications provide concrete analytics providers or adapters, while feature modules emit typed domain analytics through Relux effects. Diagnostics packages remain focused on logging, diagnostic events, and error tracking.

## Scope
(define epic scope)

## Acceptance Criteria
- Package exposes a ReluxAnalytics library product with Swift 6 strict settings.
- Product analytics core models are not hosted in diagnostics packages.
- Instant events, continuous events, analytics lifecycle start, identify, and reset identity are modeled in the package.
- Relux Effect/Saga/Module wrappers route analytics commands to an injected service.
- SwiftUI helpers allow UI instrumentation through Relux effects.
- Tests cover continuous event aggregation, service routing, and helper command shape where practical.
- README documents package purpose, architecture, APIs, and local tool commands.
