public extension Analytics {
    protocol Service: Sendable {
        var currentIdentityState: IdentityState { get async }

        func start() async
        func identify(_ identity: Identity) async
        func resetIdentity() async
        func track(_ event: Event) async
    }

    actor DefaultService: Service {
        private let aggregators: [any Aggregator]
        private let contextProviders: [any ContextProvider]
        private let continuousEventManager: any ContinuousEventManager
        private var identityState: IdentityState = .notIdentified
        private var continuousAggregationTask: Task<Void, Never>?

        public var currentIdentityState: IdentityState {
            identityState
        }

        public init(
            aggregators: [any Aggregator] = [],
            continuousEventManager: any ContinuousEventManager = DefaultContinuousEventManager(),
            contextProviders: [any ContextProvider] = []
        ) {
            self.aggregators = aggregators
            self.contextProviders = contextProviders
            self.continuousEventManager = continuousEventManager
        }

        deinit {
            continuousAggregationTask?.cancel()
        }

        public func start() async {
            await continuousEventManager.startStaleMonitoring()
            await observeContinuousAggregatesIfNeeded()
            for aggregator in aggregators {
                await aggregator.start()
            }
        }

        public func identify(_ identity: Identity) async {
            identityState = .identified(identity)
            for aggregator in aggregators {
                await aggregator.identify(identity)
            }
        }

        public func resetIdentity() async {
            identityState = .notIdentified
            for aggregator in aggregators {
                await aggregator.resetIdentity()
            }
        }

        public func track(_ event: Event) async {
            switch event {
            case let .instant(event):
                await trackInstantEvent(event)
            case let .continuous(event):
                await continuousEventManager.handle(event)
            }
        }

        private func observeContinuousAggregatesIfNeeded() async {
            guard continuousAggregationTask == nil else { return }

            let stream = await continuousEventManager.aggregates()
            continuousAggregationTask = Task { [weak self] in
                for await aggregate in stream {
                    guard Task.isCancelled == false else { return }
                    await self?.trackContinuousAggregate(aggregate)
                }
            }
        }

        private func trackContinuousAggregate(_ aggregate: ContinuousEventAggregate) async {
            let context = await contextParameters()
            let enrichedAggregate = aggregate.withCollectorParameters(
                aggregate.collectorParameters.withContext(context)
            )

            for aggregator in aggregators {
                await aggregator.track(.continuousAggregate(enrichedAggregate))
            }
        }

        private func trackInstantEvent(_ event: InstantEvent) async {
            let context = await contextParameters()
            let enrichedEvent = InstantEvent(
                name: event.name,
                timestamp: event.timestamp,
                parameters: event.parameters.withContext(context)
            )

            for aggregator in aggregators {
                await aggregator.track(.instant(enrichedEvent))
            }
        }

        private func contextParameters() async -> Parameters {
            var parameters = Parameters()

            for provider in contextProviders {
                let providedParameters = await provider.parameters()
                parameters.merge(providedParameters) { _, new in new }
            }

            return parameters
        }
    }
}
