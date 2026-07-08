public extension Analytics {
    enum Event: Equatable, Sendable {
        case instant(InstantEvent)
        case continuous(ContinuousEvent)
    }

    enum CollectorEvent: Equatable, Sendable {
        case instant(InstantEvent)
        case continuousAggregate(ContinuousEventAggregate)
    }
}
