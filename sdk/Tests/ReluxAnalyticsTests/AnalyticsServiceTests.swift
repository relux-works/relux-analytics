import Foundation
import Testing
@testable import ReluxAnalytics

@Suite("Analytics service")
struct AnalyticsServiceTests {
    @Test func serviceCachesIdentityAndForwardsIdentityCalls() async {
        let aggregator = RecordingAggregator()
        let service = Analytics.DefaultService(aggregators: [aggregator])
        let identity = Analytics.Identity(
            userID: "analytics-user-1",
            properties: [
                "cohort": .string("pilot"),
                "is_employee": .bool(false)
            ]
        )

        #expect(await service.currentIdentityState == .notIdentified)

        await service.identify(identity)

        #expect(await service.currentIdentityState == .identified(identity))
        #expect(await aggregator.identities == [identity])

        await service.resetIdentity()

        #expect(await service.currentIdentityState == .notIdentified)
        #expect(await aggregator.resetIdentityCount == 1)
    }

    @Test func serviceForwardsInstantEvents() async {
        let aggregator = RecordingAggregator()
        let service = Analytics.DefaultService(aggregators: [aggregator])
        let event = Analytics.InstantEvent(
            name: "transfer_confirm_tapped",
            parameters: ["amount_bucket": .string("small")]
        )

        await service.track(.instant(event))

        #expect(await aggregator.instantEvents == [event])
    }

    @Test func serviceAddsContextToInstantEventsWithEventAndReservedPrecedence() async {
        let aggregator = RecordingAggregator()
        let service = Analytics.DefaultService(
            aggregators: [aggregator],
            contextProviders: [
                Analytics.StaticContextProvider([
                    "local_platform": .string("ios"),
                    "amount_bucket": .string("global"),
                    "event_family": .string("broken")
                ])
            ]
        )
        let event = Analytics.InstantEvent(
            name: "transfer_confirm_tapped",
            parameters: ["amount_bucket": .string("small")]
        )

        await service.track(.instant(event))

        let trackedEvent = await aggregator.instantEvents.first

        #expect(trackedEvent?.collectorParameters["local_platform"] == .string("ios"))
        #expect(trackedEvent?.collectorParameters["amount_bucket"] == .string("small"))
        #expect(trackedEvent?.collectorParameters["event_family"] == .string("instant"))
    }

    @Test func serviceForwardsContinuousAggregatesAfterStart() async {
        let aggregator = RecordingAggregator()
        let manager = Analytics.DefaultContinuousEventManager()
        let service = Analytics.DefaultService(
            aggregators: [aggregator],
            continuousEventManager: manager
        )
        let start = Date(timeIntervalSince1970: 400)
        let spanID = Analytics.SpanID("span-service")

        await service.start()
        await service.track(
            .continuous(
                .start(
                    .init(
                        name: "screen_visible_started",
                        finishEventName: "screen_visible_stopped",
                        spanID: spanID,
                        timestamp: start,
                        staleTimeout: 10
                    )
                )
            )
        )
        await service.track(
            .continuous(
                .stop(
                    .init(
                        name: "screen_visible_stopped",
                        spanID: spanID,
                        timestamp: start.addingTimeInterval(4)
                    )
                )
            )
        )

        try? await Task.sleep(nanoseconds: 20_000_000)

        #expect(await aggregator.continuousAggregates.map(\.spanID) == [spanID])
        #expect(await aggregator.startCount == 1)
    }

    @Test func serviceAddsContextToContinuousAggregatesWithAggregatePrecedence() async {
        let aggregator = RecordingAggregator()
        let manager = Analytics.DefaultContinuousEventManager()
        let service = Analytics.DefaultService(
            aggregators: [aggregator],
            continuousEventManager: manager,
            contextProviders: [
                Analytics.StaticContextProvider([
                    "local_platform": .string("ios"),
                    "span_id": .string("broken"),
                    "start.screen": .string("global")
                ])
            ]
        )
        let start = Date(timeIntervalSince1970: 500)
        let spanID = Analytics.SpanID("span-context")

        await service.start()
        await service.track(
            .continuous(
                .start(
                    .init(
                        name: "transfer_attempt_started",
                        finishEventName: "transfer_attempt_finished",
                        spanID: spanID,
                        timestamp: start,
                        staleTimeout: 10,
                        parameters: ["screen": .string("confirmation")]
                    )
                )
            )
        )
        await service.track(
            .continuous(
                .stop(
                    .init(
                        name: "transfer_attempt_finished",
                        spanID: spanID,
                        timestamp: start.addingTimeInterval(4)
                    )
                )
            )
        )

        try? await Task.sleep(nanoseconds: 20_000_000)

        let aggregate = await aggregator.continuousAggregates.first

        #expect(aggregate?.collectorParameters["local_platform"] == .string("ios"))
        #expect(aggregate?.collectorParameters["span_id"] == .string("span-context"))
        #expect(aggregate?.collectorParameters["start.screen"] == .string("confirmation"))
    }
}

@Suite("Analytics saga")
struct AnalyticsSagaTests {
    @Test func sagaRoutesEffectsToService() async {
        let service = RecordingService()
        let saga = Analytics.Saga(service: service)
        let identity = Analytics.Identity(userID: "user-1")
        let instant = Analytics.InstantEvent(name: "send_opened")
        let continuous = Analytics.ContinuousEvent.start(
            .init(
                name: "lookup_started",
                finishEventName: "lookup_stopped",
                staleTimeout: 10
            )
        )

        await saga.apply(Analytics.Effect.start)
        await saga.apply(Analytics.Effect.identify(identity))
        await saga.apply(Analytics.Effect.track(.instant(instant)))
        await saga.apply(Analytics.Effect.track(.continuous(continuous)))
        await saga.apply(Analytics.Effect.resetIdentity)

        #expect(await service.startCount == 1)
        #expect(await service.identities == [identity])
        #expect(await service.events == [.instant(instant), .continuous(continuous)])
        #expect(await service.resetIdentityCount == 1)
    }
}

private actor RecordingAggregator: Analytics.Aggregator {
    private(set) var startCount = 0
    private(set) var identities: [Analytics.Identity] = []
    private(set) var resetIdentityCount = 0
    private(set) var instantEvents: [Analytics.InstantEvent] = []
    private(set) var continuousAggregates: [Analytics.ContinuousEventAggregate] = []

    func start() async {
        startCount += 1
    }

    func identify(_ identity: Analytics.Identity) async {
        identities.append(identity)
    }

    func resetIdentity() async {
        resetIdentityCount += 1
    }

    func track(_ event: Analytics.CollectorEvent) async {
        switch event {
        case let .instant(event):
            instantEvents.append(event)
        case let .continuousAggregate(aggregate):
            continuousAggregates.append(aggregate)
        }
    }
}

private actor RecordingService: Analytics.Service {
    private var identityState: Analytics.IdentityState = .notIdentified
    private(set) var startCount = 0
    private(set) var identities: [Analytics.Identity] = []
    private(set) var resetIdentityCount = 0
    private(set) var events: [Analytics.Event] = []

    var currentIdentityState: Analytics.IdentityState {
        identityState
    }

    func start() async {
        startCount += 1
    }

    func identify(_ identity: Analytics.Identity) async {
        identityState = .identified(identity)
        identities.append(identity)
    }

    func resetIdentity() async {
        identityState = .notIdentified
        resetIdentityCount += 1
    }

    func track(_ event: Analytics.Event) async {
        events.append(event)
    }
}
