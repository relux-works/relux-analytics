import Relux

public extension Analytics {
    final class Module: Relux.Module {
        public let states: [any Relux.AnyState]
        public let sagas: [any Relux.Saga]
        public let service: any Analytics.Service

        public init(service: any Analytics.Service) {
            self.service = service
            self.states = []
            self.sagas = [Analytics.Saga(service: service)]
        }

        public convenience init(
            aggregators: [any Analytics.Aggregator] = [],
            continuousEventManager: any Analytics.ContinuousEventManager = Analytics.DefaultContinuousEventManager(),
            contextProviders: [any Analytics.ContextProvider] = []
        ) {
            self.init(
                service: Analytics.DefaultService(
                    aggregators: aggregators,
                    continuousEventManager: continuousEventManager,
                    contextProviders: contextProviders
                )
            )
        }
    }
}
