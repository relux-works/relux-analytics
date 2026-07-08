import Foundation

public extension Analytics {
    enum EventFamily: String, Equatable, Sendable {
        case instant
        case continuous
    }

    enum ReservedParameterKey {
        public static let eventFamily = "event_family"
        public static let spanID = "span_id"
        public static let startEventName = "start_event_name"
        public static let finishEventName = "finish_event_name"
        public static let continuousState = "continuous_state"
        public static let closeReason = "close_reason"
        public static let durationMilliseconds = "duration_ms"
        public static let staleTimeoutMilliseconds = "stale_timeout_ms"
    }

    struct InstantEvent: Equatable, Sendable {
        public let name: String
        public let timestamp: Date
        public let parameters: Parameters

        public init(
            name: String,
            timestamp: Date = Date(),
            parameters: Parameters = [:]
        ) {
            self.name = name
            self.timestamp = timestamp
            self.parameters = parameters
        }

        public var collectorParameters: Parameters {
            parameters.withReserved([
                ReservedParameterKey.eventFamily: .string(EventFamily.instant.rawValue)
            ])
        }
    }
}
