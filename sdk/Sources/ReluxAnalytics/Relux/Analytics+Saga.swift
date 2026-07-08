import Relux

public extension Analytics {
    actor Saga: Relux.Saga {
        private let service: any Analytics.Service

        public init(service: any Analytics.Service) {
            self.service = service
        }

        public func apply(_ effect: any Relux.Effect) async {
            switch effect as? Analytics.Effect {
            case .none:
                return
            case .start:
                await service.start()
            case let .identify(identity):
                await service.identify(identity)
            case .resetIdentity:
                await service.resetIdentity()
            case let .track(event):
                await service.track(event)
            }
        }
    }
}
