import Relux

public extension Analytics {
    enum Effect: Relux.Effect {
        case start
        case identify(Identity)
        case resetIdentity
        case track(Event)
    }
}
