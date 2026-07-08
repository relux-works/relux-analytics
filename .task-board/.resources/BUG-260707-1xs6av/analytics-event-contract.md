# ReluxAnalytics Event Contract

## Scope

This spec defines the analytics contract used by the SDK, Relux effects, SwiftUI helpers, AppMetrica integration, and the sample app.

## Goals

- Keep the public analytics API event-oriented.
- Keep continuous event aggregation internal to the SDK.
- Let product code emit instant events and continuous start/update/stop events without owning span maps or timeout loops.
- Let ready integrations, such as AppMetrica, be usable as complete services while still allowing custom collector sinks.

## Public Event API

Product code emits `Analytics.Event`.

```swift
public enum Analytics.Event {
    case instant(Analytics.InstantEvent)
    case continuous(Analytics.ContinuousEvent)
}
```

Instant events are one-shot metrics. When the caller sends an instant event, the service forwards it to collector sinks immediately.

Continuous events are lifecycle events. The caller sends start/update/stop events. The caller does not create aggregates.

```swift
public enum Analytics.ContinuousEvent {
    case start(Analytics.ContinuousStartEvent)
    case update(Analytics.ContinuousUpdateEvent)
    case stop(Analytics.ContinuousStopEvent)
}
```

The Relux effect API uses the same public event contract:

```swift
Analytics.Effect.track(.instant(event))
Analytics.Effect.track(.continuous(.start(startEvent)))
Analytics.Effect.track(.continuous(.stop(stopEvent)))
```

## Internal Continuous Pipeline

`Analytics.ContinuousEventManager` owns active span state:

- Stores started spans by `SpanID`.
- Merges update parameters into the active span.
- Closes spans on stop.
- Sweeps stale spans by timeout.
- Emits `Analytics.ContinuousEventAggregate` through `AsyncStream`.

`Analytics.ContinuousEventAggregate` is an internal collector-ready aggregate. Product UI and feature code must not be required to construct it.

## Service Pipeline

`Analytics.Service` owns identity state and event routing:

- `start()` starts collector sinks and starts continuous stale monitoring.
- `identify(_:)` caches identity state and forwards identity to sinks.
- `resetIdentity()` clears identity state and forwards reset to sinks.
- `track(_:)` routes public `Analytics.Event`.
- Instant events are forwarded to sinks immediately.
- Continuous events are passed to `ContinuousEventManager`.
- Aggregates produced by `ContinuousEventManager` are forwarded to sinks.

## Service Contracts

### `Analytics.Service`

`Analytics.Service` is the product-facing runtime contract. Relux sagas, SwiftUI helpers, and feature flows talk to this protocol.

```swift
public protocol Analytics.Service: Sendable {
    var currentIdentityState: Analytics.IdentityState { get async }

    func start() async
    func identify(_ identity: Analytics.Identity) async
    func resetIdentity() async
    func track(_ event: Analytics.Event) async
}
```

Contract rules:

- `start()` initializes the analytics machinery. It is idempotent from the caller point of view.
- `identify(_:)` moves the service to `.identified(identity)` and forwards identity to the underlying collector implementation.
- `resetIdentity()` moves the service to `.notIdentified` and forwards identity reset to the collector implementation.
- `track(.instant)` sends a one-shot event to the collector side immediately.
- `track(.continuous)` accepts only lifecycle events: start/update/stop. It never accepts `ContinuousEventAggregate` from product code.
- Services that support continuous metrics must use an injected `ContinuousEventManager` or a behaviorally equivalent implementation.
- The service owns the subscription from manager aggregates to collector sinks.

### `Analytics.ContinuousEventManager`

`Analytics.ContinuousEventManager` is an SDK-provided dependency for services.

```swift
public protocol Analytics.ContinuousEventManager: Sendable {
    func startStaleMonitoring() async
    func stopStaleMonitoring() async
    func aggregates() async -> AsyncStream<Analytics.ContinuousEventAggregate>
    func handle(_ event: Analytics.ContinuousEvent) async
    func sweepStale(now: Date) async
}
```

Contract rules:

- `handle(.start)` creates or replaces active span state by `SpanID`.
- `handle(.update)` merges update parameters into an active span.
- `handle(.stop)` closes an active span and emits exactly one aggregate when the span exists.
- `sweepStale(now:)` emits timeout aggregates for stale spans.
- `aggregates()` is the only source of `ContinuousEventAggregate` for service implementations.

### `Analytics.Aggregator`

`Analytics.Aggregator` is a low-level collector sink contract, not the product-facing service API.

```swift
public protocol Analytics.Aggregator: Sendable {
    func start() async
    func identify(_ identity: Analytics.Identity) async
    func resetIdentity() async
    func track(_ event: Analytics.CollectorEvent) async
}
```

Contract rules:

- Aggregators receive collector-ready events only.
- Aggregators may receive `.instant`.
- Aggregators may receive `.continuousAggregate`.
- Aggregators do not receive `.continuous(.start/.update/.stop)`.
- Aggregators do not own active span maps or stale timeout loops.

### `Analytics.AppMetricaService`

`ReluxAnalyticsAppMetrica` provides a ready service implementation for products that want AppMetrica without writing their own manager subscription.

```swift
public actor Analytics.AppMetricaService: Analytics.Service {
    public init(
        apiKey: String,
        continuousEventManager: any Analytics.ContinuousEventManager = Analytics.DefaultContinuousEventManager()
    )
}
```

Contract rules:

- AppMetrica setup is hidden behind the service.
- The service receives the same public `Analytics.Event` as any other service.
- The service routes continuous lifecycle events into `ContinuousEventManager`.
- The service reports manager-produced aggregates to AppMetrica.
- Sample UI and product code do not import `AppMetricaCore` and do not construct aggregates.

## Collector Sink Contract

Collector sinks receive collector-ready events:

```swift
public enum Analytics.CollectorEvent {
    case instant(Analytics.InstantEvent)
    case continuousAggregate(Analytics.ContinuousEventAggregate)
}
```

An `Analytics.Aggregator` is a low-level collector sink. It receives `CollectorEvent`, not public continuous start/stop events.

Ready product integrations may expose complete `Analytics.Service` implementations when they need to own the continuous manager subscription and collector SDK setup. The AppMetrica integration does this.

## AppMetrica Integration

`ReluxAnalyticsAppMetrica` provides `Analytics.AppMetricaService`.

The service:

- Accepts `apiKey` and an injectable `Analytics.ContinuousEventManager`.
- Activates AppMetrica on `start()`.
- Tracks `Analytics.Event.instant` directly.
- Passes `Analytics.Event.continuous` to the manager.
- Subscribes to manager aggregates and reports resulting continuous aggregate events to AppMetrica.
- Maps SDK values to AppMetrica parameters.
- Keeps `Analytics.ContinuousEventAggregate` out of sample UI and product code.

## Sample Verification Flow

The sample app must expose controls for:

- Reset identity.
- Identify sample user.
- Track anonymous instant.
- Track identified instant.
- Start/stop anonymous continuous.
- Start/stop identified continuous.

UI tests must exercise these controls before any browser/AppMetrica dashboard verification.

The final AppMetrica E2E verification uses the same sample flow and then checks that expected event names or run identifiers appear in the authenticated AppMetrica project.
