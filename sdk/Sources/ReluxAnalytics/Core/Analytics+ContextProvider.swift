public extension Analytics {
    protocol ContextProvider: Sendable {
        func parameters() async -> Parameters
    }

    struct StaticContextProvider: ContextProvider {
        private let storedParameters: Parameters

        public init(_ parameters: Parameters) {
            self.storedParameters = parameters
        }

        public func parameters() async -> Parameters {
            storedParameters
        }
    }
}
