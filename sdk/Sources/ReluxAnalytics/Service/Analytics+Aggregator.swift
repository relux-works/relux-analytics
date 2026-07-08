public extension Analytics {
    protocol Aggregator: Sendable {
        func start() async
        func identify(_ identity: Identity) async
        func resetIdentity() async
        func track(_ event: CollectorEvent) async
    }
}

public extension Analytics.Aggregator {
    func start() async {}
    func identify(_ identity: Analytics.Identity) async {}
    func resetIdentity() async {}
    func track(_ event: Analytics.CollectorEvent) async {}
}
