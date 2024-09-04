import Relux

extension Analytics {
    public enum SideEffect: Relux.Effect {
        case setup
        case setUserProperties(Analytics.Data)
        case track(Analytics.Event, Analytics.Data? = nil)
    }
}
