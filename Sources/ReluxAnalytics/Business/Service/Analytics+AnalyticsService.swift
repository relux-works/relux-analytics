public extension Analytics {
    actor AnalyticsService: Analytics.IAnalyticsService {
        private let aggregators: [any Analytics.IAnalyticsAggregator]

        public init(
                aggregators: [any Analytics.IAnalyticsAggregator]
        ) {
            self.aggregators = aggregators
        }

		public func setup(userId: String) async throws {
           try await aggregators.concurrentForEach { try await $0.setup(userId: userId) }
        }
        
        public func setUserProperties(_ userProperties: Analytics.Data) async throws {
           try await aggregators.concurrentForEach { try await $0.setUserProperties(userProperties) }
        }
        
		public func track(_ event: Event) async throws {
            try await track(event, nil)
        }

		public func track(_ event: Event, _ data: Analytics.Data?) async throws {
            try await aggregators.concurrentForEach { try await $0.track(event, data) }
        }
    }
}
