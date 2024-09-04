import Relux

extension Analytics {
    public final class Module: Relux.Module {
        public let states: [any Relux.State]
        public let uistates: [any Relux.Presentation.StatePresenting]
        public let sagas: [any Relux.Saga]
        public let routers: [any Relux.Navigation.RouterProtocol]
        
        public init(
            sagas: [Analytics.Saga]
        ) {
            self.sagas = sagas
            self.states = []
            self.uistates = []
            self.routers = []
        }
    }
}
