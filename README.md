<<<<<<< HEAD
# relux-analytics

Relux module for product analytics. Analytics events are ordinary
[Relux](https://github.com/relux-works/swift-relux) actions: views declare events,
a saga routes them through side effects, and vendor adapters deliver them. The core
stays vendor agnostic; pair it with an adapter such as
[relux-analytics-amplitude](https://github.com/relux-works/relux-analytics-amplitude).

## Installation (Swift Package Manager)

```swift
.package(url: "https://github.com/relux-works/relux-analytics.git", from: "1.0.0")
```

```swift
.product(name: "ReluxAnalytics", package: "relux-analytics")
```

## Usage

Register the module in your Relux runtime, then emit events from views or business
logic as actions. SwiftUI helpers cover screen-view tracking. A working setup is shown
in [relux-analytics-sample](https://github.com/relux-works/relux-analytics-sample).

## The Relux stack

This package is part of the Relux stack: the
[Relux](https://github.com/relux-works/swift-relux) unidirectional data-flow
architecture for Swift 6, a family of modules around it, and agent-ready testing
tools. The stack is how we build MVPs fast on agentic rails and then scale them into
enterprise-grade apps: Tuist workspaces, strict modularization, and a UDF architecture
proven in production for years. Browse the full picture in the
[Relux Works open-source catalog](https://relux.works/en/open-source/).

<!-- relux-ecosystem:start -->

## About Relux Works

This project is part of the open-source ecosystem of
[Relux Works](https://relux.works), an AI-native software development studio.
We build fixed-price MVPs, rescue vibe-coded apps, run local AI inference, and
train teams to work with coding agents. Much of the infrastructure behind that
work is open source.

- Full catalog: [relux.works/en/open-source](https://relux.works/en/open-source/)
- Agentic enablement: [agent harnesses & team training](https://relux.works/en/agentic-enablement/)
- Hire us the agent-native way: point your assistant at `https://api.relux.works/mcp`
- Contact: ivan@relux.works

<!-- relux-ecosystem:end -->

## License

See [LICENSE](LICENSE).
=======
# ReluxAnalytics

ReluxAnalytics is a Relux-oriented analytics SDK workspace.

The repository contains the reusable SDK, optional collector integrations, and an iOS sample app that exercises the current AppMetrica integration.

## Repository Layout

- `sdk/` - SwiftPM package that exports `ReluxAnalytics`.
- `integrations/appmetrica/` - SwiftPM package that exports `ReluxAnalyticsAppMetrica`.
- `sample/` - Tuist iOS sample app that consumes the local SDK and AppMetrica integration.
- `.spec/` - product and architecture specs used by the task board.
- `.task-board/` - file-backed task board for implementation tracking.
- `.temp/` - ignored logs, derived validation artifacts, screenshots, and scratch files.

## Architecture

Product code emits `Analytics.Event`.

Instant events are sent as one-shot metrics. Continuous events are sent as lifecycle commands: start, update, and stop. Product UI and feature code never build continuous aggregates by hand.

The SDK owns the lower-level mechanics:

- `Analytics.Service` is the product-facing runtime contract.
- `Analytics.ContinuousEventManager` owns active span state, stale timeout sweeps, and aggregate emission.
- `Analytics.Aggregator` is a collector sink that receives collector-ready events.
- `Analytics.Effect`, `Analytics.Saga`, and `Analytics.Module` wire the service into Relux.
- SwiftUI helpers dispatch analytics through Relux effects from the rendered view hierarchy.

The detailed event contract is in `.spec/analytics-event-contract.md`.

## AppMetrica Sample

The sample uses AppMetrica as the first concrete collector integration.

- AppMetrica overview: `https://appmetrica.yandex.com/overview?appId=6324763&period=week&group=day&currency=rub&accuracy=medium`
- AppMetrica app id: `6324763`
- Sample API key: `YOUR_APPMETRICA_API_KEY`
- Integration docs: `https://appmetrica.yandex.com/docs/en/sdk/ios/analytics/quick-start?tabs=defaultTabsGroup-v5q7vdkn_spm%2520in%2520xcode`
- SPM package URL: `https://github.com/appmetrica/appmetrica-sdk-ios`
- Required AppMetrica product: `AppMetricaCore`
- Required linker flags: `$(inherited) -ObjC`

Put the real local AppMetrica key into
`sample/Targets/ReluxAnalyticsSample/Sources/App/ReluxAnalyticsSample.Registry.swift`
when running dashboard verification. Do not commit the real key; keep the
checked-in value as `YOUR_APPMETRICA_API_KEY`.

The integration package exposes `Analytics.AppMetricaService`, which conforms to `Analytics.Service`. The sample resolves that service through IoC, registers `Analytics.Module`, and dispatches startup, identity, instant, and continuous events from rendered content.

`Analytics.AppMetricaService` keeps AppMetrica's default buffered delivery by default. The sample opts into `eventsBufferFlushPolicy: .afterEveryReport` so local UI/e2e runs can be checked in the AppMetrica dashboard without waiting for the SDK's normal batch upload window.

Live dashboard ingestion was verified on 2026-07-08 in the AppMetrica Events report for app `6324763`: the report showed 39 total events for the selected week and 32 events on July 8 after the sample UI test run.

## Tools

### SwiftPM

Used for the SDK and integration packages.

```bash
swift test --package-path sdk
```

SwiftPM build products live under package-local `.build/` directories and are ignored.

The AppMetrica integration is iOS-only. Verify it through the sample iOS build
instead of a host macOS `swift build`.

### Tuist

Used for the iOS sample project.

```bash
cd sample
tuist install
tuist generate
```

Generated Xcode projects/workspaces and Tuist derived output are ignored.

### xcodebuild

Used for sample build and UI test verification.

```bash
cd sample
xcodebuild -workspace ReluxAnalyticsSample.xcworkspace \
  -scheme ReluxAnalyticsSample \
  -destination 'generic/platform=iOS Simulator' \
  build
```

Store build logs and `.xcresult` bundles under `.temp/`.

### task-board

Used for task tracking.

```bash
task-board q --format compact 'summary()'
task-board validate
```

The board lives under `.task-board/` and should be committed with implementation state.

### rg

Used for source search.

```bash
rg "Analytics.Event"
```

Search output is not persisted unless it is part of a task outcome.

## Artifact Policy

Use `.temp/` for local logs, screenshots, browser verification notes, Xcode result bundles, and other scratch artifacts.

Do not commit SwiftPM `.build/`, Tuist `Derived/`, Xcode projects/workspaces generated by Tuist, or local derived-data logs.
>>>>>>> e94943f (Document ReluxAnalytics workspace and task board)
