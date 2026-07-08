import Foundation
import Testing
@testable import ReluxAnalytics

@Suite("Analytics core")
struct AnalyticsCoreTests {
    @Test func instantEventAddsCollectorFamily() {
        let event = Analytics.InstantEvent(
            name: "transfer_confirm_tapped",
            parameters: ["amount_bucket": .string("small")]
        )

        #expect(event.collectorParameters["event_family"] == .string("instant"))
        #expect(event.collectorParameters["amount_bucket"] == .string("small"))
    }

    @Test func continuousManagerEmitsAggregateOnStop() async {
        let manager = Analytics.DefaultContinuousEventManager()
        let stream = await manager.aggregates()
        var iterator = stream.makeAsyncIterator()
        let start = Date(timeIntervalSince1970: 100)
        let spanID = Analytics.SpanID("span-stop")

        await manager.handle(
            .start(
                .init(
                    name: "receive_waiting_started",
                    finishEventName: "receive_waiting_stopped",
                    spanID: spanID,
                    timestamp: start,
                    staleTimeout: 30,
                    parameters: ["screen": .string("receive")]
                )
            )
        )
        await manager.handle(
            .update(
                .init(
                    spanID: spanID,
                    timestamp: start.addingTimeInterval(2),
                    parameters: ["rssi_score": .int(8)]
                )
            )
        )
        await manager.handle(
            .stop(
                .init(
                    name: "receive_waiting_stopped",
                    spanID: spanID,
                    timestamp: start.addingTimeInterval(5),
                    reason: .completed,
                    parameters: ["result": .string("matched")]
                )
            )
        )

        let aggregate = await iterator.next()

        #expect(aggregate?.spanID == spanID)
        #expect(aggregate?.startEventName == "receive_waiting_started")
        #expect(aggregate?.finishEventName == "receive_waiting_stopped")
        #expect(aggregate?.state == .fired)
        #expect(aggregate?.reason == .completed)
        #expect(aggregate?.duration == 5)
        #expect(aggregate?.staleTimeout == 30)
        #expect(aggregate?.collectorParameters["event_family"] == .string("continuous"))
        #expect(aggregate?.collectorParameters["span_id"] == .string("span-stop"))
        #expect(aggregate?.collectorParameters["duration_ms"] == .int(5000))
        #expect(aggregate?.collectorParameters["stale_timeout_ms"] == .int(30000))
        #expect(aggregate?.collectorParameters["start.screen"] == .string("receive"))
        #expect(aggregate?.collectorParameters["latest.rssi_score"] == .int(8))
        #expect(aggregate?.collectorParameters["finish.result"] == .string("matched"))
    }

    @Test func continuousManagerEmitsAggregateOnStaleTimeout() async {
        let manager = Analytics.DefaultContinuousEventManager()
        let stream = await manager.aggregates()
        var iterator = stream.makeAsyncIterator()
        let start = Date(timeIntervalSince1970: 200)
        let timeout = start.addingTimeInterval(3)
        let spanID = Analytics.SpanID("span-timeout")

        await manager.handle(
            .start(
                .init(
                    name: "sender_waiting_started",
                    finishEventName: "sender_waiting_stopped",
                    spanID: spanID,
                    timestamp: start,
                    staleTimeout: 3,
                    parameters: ["flow": .string("send")]
                )
            )
        )
        await manager.sweepStale(now: timeout)

        let aggregate = await iterator.next()

        #expect(aggregate?.spanID == spanID)
        #expect(aggregate?.finishEventName == "sender_waiting_stopped")
        #expect(aggregate?.state == .timedOut)
        #expect(aggregate?.reason == .staleTimeout)
        #expect(aggregate?.duration == 3)
        #expect(aggregate?.staleTimeout == 3)
        #expect(aggregate?.collectorParameters["event_family"] == .string("continuous"))
        #expect(aggregate?.collectorParameters["continuous_state"] == .string("timed_out"))
        #expect(aggregate?.collectorParameters["close_reason"] == .string("stale_timeout"))
        #expect(aggregate?.collectorParameters["duration_ms"] == .int(3000))
        #expect(aggregate?.collectorParameters["stale_timeout_ms"] == .int(3000))
        #expect(aggregate?.collectorParameters["start.flow"] == .string("send"))
    }

    @Test func continuousManagerEmitsReplacedAggregateWhenSpanRestarts() async {
        let manager = Analytics.DefaultContinuousEventManager()
        let stream = await manager.aggregates()
        var iterator = stream.makeAsyncIterator()
        let firstStart = Date(timeIntervalSince1970: 250)
        let secondStart = firstStart.addingTimeInterval(4)
        let stop = secondStart.addingTimeInterval(3)
        let spanID = Analytics.SpanID("span-replaced")

        await manager.handle(
            .start(
                .init(
                    name: "screen_session_started",
                    finishEventName: "screen_session_stopped",
                    spanID: spanID,
                    timestamp: firstStart,
                    staleTimeout: 30,
                    parameters: ["attempt": .int(1)]
                )
            )
        )
        await manager.handle(
            .update(
                .init(
                    spanID: spanID,
                    timestamp: firstStart.addingTimeInterval(2),
                    parameters: ["step": .string("first")]
                )
            )
        )
        await manager.handle(
            .start(
                .init(
                    name: "screen_session_started",
                    finishEventName: "screen_session_stopped",
                    spanID: spanID,
                    timestamp: secondStart,
                    staleTimeout: 30,
                    parameters: ["attempt": .int(2)]
                )
            )
        )
        await manager.handle(
            .stop(
                .init(
                    name: "screen_session_stopped",
                    spanID: spanID,
                    timestamp: stop,
                    reason: .completed,
                    parameters: ["result": .string("second_finished")]
                )
            )
        )

        let replaced = await iterator.next()
        let completed = await iterator.next()

        #expect(replaced?.spanID == spanID)
        #expect(replaced?.reason == .replaced)
        #expect(replaced?.duration == 4)
        #expect(replaced?.collectorParameters["close_reason"] == .string("replaced"))
        #expect(replaced?.collectorParameters["start.attempt"] == .int(1))
        #expect(replaced?.collectorParameters["latest.step"] == .string("first"))

        #expect(completed?.spanID == spanID)
        #expect(completed?.reason == .completed)
        #expect(completed?.duration == 3)
        #expect(completed?.collectorParameters["start.attempt"] == .int(2))
        #expect(completed?.collectorParameters["finish.result"] == .string("second_finished"))
    }

    @Test func continuousManagerMonitoringLoopEmitsStaleAggregate() async {
        let start = Date(timeIntervalSince1970: 300)
        let timeout = start.addingTimeInterval(2)
        let manager = Analytics.DefaultContinuousEventManager(
            staleCheckInterval: 0.001,
            dateProvider: { timeout }
        )
        let stream = await manager.aggregates()
        var iterator = stream.makeAsyncIterator()
        let spanID = Analytics.SpanID("span-auto-timeout")

        await manager.handle(
            .start(
                .init(
                    name: "otp_entry_started",
                    finishEventName: "otp_entry_stopped",
                    spanID: spanID,
                    timestamp: start,
                    staleTimeout: 2
                )
            )
        )
        await manager.startStaleMonitoring()

        let aggregate = await iterator.next()

        await manager.stopStaleMonitoring()

        #expect(aggregate?.spanID == spanID)
        #expect(aggregate?.state == .timedOut)
        #expect(aggregate?.reason == .staleTimeout)
        #expect(aggregate?.collectorParameters["stale_timeout_ms"] == .int(2000))
    }
}
