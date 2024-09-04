public extension Analytics {
	struct Event: Sendable  {
        public var rawValue: String
		
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension Analytics.Event {
    public func with(_ action: Analytics.Action) -> Analytics.Event {
        .init(rawValue: "\(self.rawValue)_\(action.rawValue)")
    }
}
