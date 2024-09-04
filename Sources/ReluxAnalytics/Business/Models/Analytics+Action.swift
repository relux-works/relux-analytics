public extension Analytics {
	struct Action: RawRepresentable, Sendable  {
        public var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
