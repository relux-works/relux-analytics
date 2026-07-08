import Foundation

public extension Analytics {
    struct SpanID: RawRepresentable, Hashable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
        public let rawValue: String

        public var description: String {
            rawValue
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: String) {
            self.rawValue = value
        }
    }

    enum ContinuousState: String, Equatable, Sendable {
        case fired
        case timedOut = "timed_out"
    }

    enum ContinuousCloseReason: String, Equatable, Sendable {
        case completed
        case cancelled
        case failed
        case replaced
        case interrupted
        case staleTimeout = "stale_timeout"
    }

    struct ContinuousStartEvent: Equatable, Sendable {
        public let name: String
        public let finishEventName: String
        public let spanID: SpanID
        public let timestamp: Date
        public let staleTimeout: TimeInterval
        public let parameters: Parameters

        public init(
            name: String,
            finishEventName: String,
            spanID: SpanID = SpanID(UUID().uuidString),
            timestamp: Date = Date(),
            staleTimeout: TimeInterval,
            parameters: Parameters = [:]
        ) {
            self.name = name
            self.finishEventName = finishEventName
            self.spanID = spanID
            self.timestamp = timestamp
            self.staleTimeout = staleTimeout
            self.parameters = parameters
        }
    }

    struct ContinuousUpdateEvent: Equatable, Sendable {
        public let spanID: SpanID
        public let timestamp: Date
        public let parameters: Parameters

        public init(
            spanID: SpanID,
            timestamp: Date = Date(),
            parameters: Parameters = [:]
        ) {
            self.spanID = spanID
            self.timestamp = timestamp
            self.parameters = parameters
        }
    }

    struct ContinuousStopEvent: Equatable, Sendable {
        public let name: String
        public let spanID: SpanID
        public let timestamp: Date
        public let reason: ContinuousCloseReason
        public let parameters: Parameters

        public init(
            name: String,
            spanID: SpanID,
            timestamp: Date = Date(),
            reason: ContinuousCloseReason = .completed,
            parameters: Parameters = [:]
        ) {
            self.name = name
            self.spanID = spanID
            self.timestamp = timestamp
            self.reason = reason
            self.parameters = parameters
        }
    }

    enum ContinuousEvent: Equatable, Sendable {
        case start(ContinuousStartEvent)
        case update(ContinuousUpdateEvent)
        case stop(ContinuousStopEvent)

        public var phase: ContinuousEventPhase {
            switch self {
            case .start:
                .start
            case .update:
                .update
            case .stop:
                .stop
            }
        }
    }

    enum ContinuousEventPhase: String, Equatable, Sendable {
        case start
        case update
        case stop
    }

    struct ContinuousEventAggregate: Equatable, Sendable {
        public let spanID: SpanID
        public let startEventName: String
        public let finishEventName: String
        public let state: ContinuousState
        public let reason: ContinuousCloseReason
        public let startTimestamp: Date
        public let finishTimestamp: Date
        public let duration: TimeInterval
        public let staleTimeout: TimeInterval
        public let startParameters: Parameters
        public let latestUpdateParameters: Parameters
        public let finishParameters: Parameters
        public let collectorParameters: Parameters

        init(
            spanID: SpanID,
            startEventName: String,
            finishEventName: String,
            state: ContinuousState,
            reason: ContinuousCloseReason,
            startTimestamp: Date,
            finishTimestamp: Date,
            duration: TimeInterval,
            staleTimeout: TimeInterval,
            startParameters: Parameters,
            latestUpdateParameters: Parameters = [:],
            finishParameters: Parameters = [:],
            collectorParameters: Parameters
        ) {
            self.spanID = spanID
            self.startEventName = startEventName
            self.finishEventName = finishEventName
            self.state = state
            self.reason = reason
            self.startTimestamp = startTimestamp
            self.finishTimestamp = finishTimestamp
            self.duration = duration
            self.staleTimeout = staleTimeout
            self.startParameters = startParameters
            self.latestUpdateParameters = latestUpdateParameters
            self.finishParameters = finishParameters
            self.collectorParameters = collectorParameters
        }
    }
}

extension Analytics.ContinuousEventAggregate {
    func withCollectorParameters(_ collectorParameters: Analytics.Parameters) -> Self {
        Self(
            spanID: spanID,
            startEventName: startEventName,
            finishEventName: finishEventName,
            state: state,
            reason: reason,
            startTimestamp: startTimestamp,
            finishTimestamp: finishTimestamp,
            duration: duration,
            staleTimeout: staleTimeout,
            startParameters: startParameters,
            latestUpdateParameters: latestUpdateParameters,
            finishParameters: finishParameters,
            collectorParameters: collectorParameters
        )
    }
}
