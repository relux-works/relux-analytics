import Foundation

public extension Analytics {
    protocol ContinuousEventManager: Sendable {
        func startStaleMonitoring() async
        func stopStaleMonitoring() async
        func aggregates() async -> AsyncStream<ContinuousEventAggregate>
        func handle(_ event: ContinuousEvent) async
        func sweepStale(now: Date) async
    }

    actor DefaultContinuousEventManager: ContinuousEventManager {
        public typealias DateProvider = @Sendable () -> Date

        private struct ActiveSpan: Sendable {
            var start: ContinuousStartEvent
            var latestUpdateTimestamp: Date?
            var latestUpdateParameters: Parameters
        }

        private var activeSpans: [SpanID: ActiveSpan] = [:]
        private var continuations: [UUID: AsyncStream<ContinuousEventAggregate>.Continuation] = [:]
        private var staleMonitoringTask: Task<Void, Never>?
        private let staleCheckInterval: TimeInterval
        private let dateProvider: DateProvider

        public init(
            staleCheckInterval: TimeInterval = 1,
            dateProvider: @escaping DateProvider = { Date() }
        ) {
            self.staleCheckInterval = staleCheckInterval
            self.dateProvider = dateProvider
        }

        deinit {
            staleMonitoringTask?.cancel()
            for continuation in continuations.values {
                continuation.finish()
            }
        }

        public func startStaleMonitoring() async {
            guard staleMonitoringTask == nil, staleCheckInterval > 0 else { return }

            let dateProvider = dateProvider
            let staleCheckInterval = staleCheckInterval
            staleMonitoringTask = Task { [weak self] in
                while Task.isCancelled == false {
                    try? await Task.sleep(nanoseconds: Self.nanoseconds(from: staleCheckInterval))
                    guard Task.isCancelled == false else { return }
                    guard let self else { return }
                    await self.sweepStale(now: dateProvider())
                }
            }
        }

        public func stopStaleMonitoring() async {
            staleMonitoringTask?.cancel()
            staleMonitoringTask = nil
        }

        public func aggregates() async -> AsyncStream<ContinuousEventAggregate> {
            let id = UUID()
            let streamAndContinuation = AsyncStream<ContinuousEventAggregate>.makeStream()
            streamAndContinuation.continuation.onTermination = { [weak self] _ in
                Task { await self?.removeContinuation(id) }
            }
            continuations[id] = streamAndContinuation.continuation
            return streamAndContinuation.stream
        }

        public func handle(_ event: ContinuousEvent) async {
            switch event {
            case let .start(event):
                if let replacedSpan = activeSpans[event.spanID] {
                    emit(Self.replacedAggregate(span: replacedSpan, timestamp: event.timestamp))
                }

                activeSpans[event.spanID] = ActiveSpan(
                    start: event,
                    latestUpdateTimestamp: nil,
                    latestUpdateParameters: [:]
                )
            case let .update(event):
                guard var span = activeSpans[event.spanID] else { return }
                span.latestUpdateTimestamp = event.timestamp
                span.latestUpdateParameters.merge(event.parameters) { _, new in new }
                activeSpans[event.spanID] = span
            case let .stop(event):
                guard let span = activeSpans.removeValue(forKey: event.spanID) else { return }
                emit(Self.aggregate(span: span, stop: event))
            }
        }

        public func sweepStale(now: Date) async {
            let staleSpanIDs = activeSpans.compactMap { spanID, span -> SpanID? in
                let referenceTimestamp = span.latestUpdateTimestamp ?? span.start.timestamp
                guard now.timeIntervalSince(referenceTimestamp) >= span.start.staleTimeout else {
                    return nil
                }
                return spanID
            }

            for spanID in staleSpanIDs {
                guard let span = activeSpans.removeValue(forKey: spanID) else { continue }
                emit(Self.timeoutAggregate(span: span, timestamp: now))
            }
        }

        private func emit(_ aggregate: ContinuousEventAggregate) {
            for continuation in continuations.values {
                continuation.yield(aggregate)
            }
        }

        private func removeContinuation(_ id: UUID) {
            continuations[id] = nil
        }

        private nonisolated static func aggregate(
            span: ActiveSpan,
            stop: ContinuousStopEvent
        ) -> ContinuousEventAggregate {
            let duration = max(0, stop.timestamp.timeIntervalSince(span.start.timestamp))
            return ContinuousEventAggregate(
                spanID: span.start.spanID,
                startEventName: span.start.name,
                finishEventName: stop.name,
                state: .fired,
                reason: stop.reason,
                startTimestamp: span.start.timestamp,
                finishTimestamp: stop.timestamp,
                duration: duration,
                staleTimeout: span.start.staleTimeout,
                startParameters: span.start.parameters,
                latestUpdateParameters: span.latestUpdateParameters,
                finishParameters: stop.parameters,
                collectorParameters: collectorParameters(
                    span: span,
                    finishEventName: stop.name,
                    state: .fired,
                    reason: stop.reason,
                    finishTimestamp: stop.timestamp,
                    finishParameters: stop.parameters
                )
            )
        }

        private nonisolated static func timeoutAggregate(
            span: ActiveSpan,
            timestamp: Date
        ) -> ContinuousEventAggregate {
            let duration = max(0, timestamp.timeIntervalSince(span.start.timestamp))
            return ContinuousEventAggregate(
                spanID: span.start.spanID,
                startEventName: span.start.name,
                finishEventName: span.start.finishEventName,
                state: .timedOut,
                reason: .staleTimeout,
                startTimestamp: span.start.timestamp,
                finishTimestamp: timestamp,
                duration: duration,
                staleTimeout: span.start.staleTimeout,
                startParameters: span.start.parameters,
                latestUpdateParameters: span.latestUpdateParameters,
                finishParameters: [:],
                collectorParameters: collectorParameters(
                    span: span,
                    finishEventName: span.start.finishEventName,
                    state: .timedOut,
                    reason: .staleTimeout,
                    finishTimestamp: timestamp,
                    finishParameters: [:]
                )
            )
        }

        private nonisolated static func replacedAggregate(
            span: ActiveSpan,
            timestamp: Date
        ) -> ContinuousEventAggregate {
            let duration = max(0, timestamp.timeIntervalSince(span.start.timestamp))
            return ContinuousEventAggregate(
                spanID: span.start.spanID,
                startEventName: span.start.name,
                finishEventName: span.start.finishEventName,
                state: .fired,
                reason: .replaced,
                startTimestamp: span.start.timestamp,
                finishTimestamp: timestamp,
                duration: duration,
                staleTimeout: span.start.staleTimeout,
                startParameters: span.start.parameters,
                latestUpdateParameters: span.latestUpdateParameters,
                finishParameters: [:],
                collectorParameters: collectorParameters(
                    span: span,
                    finishEventName: span.start.finishEventName,
                    state: .fired,
                    reason: .replaced,
                    finishTimestamp: timestamp,
                    finishParameters: [:]
                )
            )
        }

        private nonisolated static func collectorParameters(
            span: ActiveSpan,
            finishEventName: String,
            state: ContinuousState,
            reason: ContinuousCloseReason,
            finishTimestamp: Date,
            finishParameters: Parameters
        ) -> Parameters {
            var parameters = span.start.parameters.prefixed("start")
            parameters.merge(span.latestUpdateParameters.prefixed("latest")) { _, new in new }
            parameters.merge(finishParameters.prefixed("finish")) { _, new in new }
            return parameters.withReserved([
                ReservedParameterKey.eventFamily: .string(EventFamily.continuous.rawValue),
                ReservedParameterKey.spanID: .string(span.start.spanID.rawValue),
                ReservedParameterKey.startEventName: .string(span.start.name),
                ReservedParameterKey.finishEventName: .string(finishEventName),
                ReservedParameterKey.continuousState: .string(state.rawValue),
                ReservedParameterKey.closeReason: .string(reason.rawValue),
                ReservedParameterKey.durationMilliseconds: .int(Int((max(0, finishTimestamp.timeIntervalSince(span.start.timestamp)) * 1000).rounded())),
                ReservedParameterKey.staleTimeoutMilliseconds: .int(Int((max(0, span.start.staleTimeout) * 1000).rounded()))
            ])
        }

        private nonisolated static func nanoseconds(from timeInterval: TimeInterval) -> UInt64 {
            UInt64(max(0, timeInterval) * 1_000_000_000)
        }
    }
}
