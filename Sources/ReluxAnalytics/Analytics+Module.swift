import Relux

extension Analytics {
    public final class Module: Relux.Module {
        public let states: [any Relux.AnyState]
        public let sagas: [any Relux.Saga]
        
        public init(
            sagas: [Analytics.Saga]
        ) {
            self.sagas = sagas
            self.states = []
        }
    }
}
