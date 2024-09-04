public extension Analytics {
    protocol IAnalyticsService: Sendable {
		func setup(userId: String) async throws
        func setUserProperties(_ userProperties: Analytics.Data) async throws
		func track(_ event: Analytics.Event) async throws
		func track(_ event: Analytics.Event, _ data: Analytics.Data?) async throws
	}
}
