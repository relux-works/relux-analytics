# TASK-260707-1jyo4h: sample-appmetrica-aggregator

## Description
Use AppMetrica as the first concrete analytics aggregator in the ReluxAnalytics sample app. Integrate AppMetrica via SPM, initialize it with API key YOUR_APPMETRICA_API_KEY, and route ReluxAnalytics instant and continuous events into AppMetrica custom events.

## Scope
Build and maintain the iOS sample app inside sample/ using the same Relux bootstrapping shape as Swipe2Cash demo: scaffold-managed SwiftIoC and Relux setup, app-local Registry/IoC builders, Relux runtime resolved asynchronously, Analytics.Module registered in the Relux builder, AppMetrica wired as an Analytics.Aggregator through IoC, and SwiftUI root rendered under Relux.Resolver.

## Acceptance Criteria
- ios-app-manager scaffold commands are used for IoC and Relux setup where supported; any remaining manual patch is documented as a scaffold gap.
- sample/Package.swift includes SwiftIoC plus local ../sdk, SwiftUIRelux, and AppMetrica dependencies.
- sample has an app-local Registry that registers Relux, Relux.Store, Relux.RootSaga, Relux.Logger, Analytics.Service, Analytics.Module, and AppMetrica-backed Analytics.Aggregator.
- App entrypoint does only synchronous app bootstrap/configuration and calls Registry.configure() before rendering Relux.Resolver.
- Relux.Resolver waits for async Registry.resolveAsync(Relux.self), runs bootstrapping effects after the runtime exists, and injects Relux/states into the SwiftUI hierarchy.
- Sample root view dispatches analytics through ReluxAnalytics helpers/effects instead of calling AppMetrica directly.
- sample project resolves dependencies, generates with Tuist, and builds for iOS Simulator.
