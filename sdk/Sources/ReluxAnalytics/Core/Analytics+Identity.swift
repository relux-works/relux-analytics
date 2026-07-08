public extension Analytics {
    struct Identity: Equatable, Sendable {
        public let userID: String
        public let properties: Parameters

        public init(
            userID: String,
            properties: Parameters = [:]
        ) {
            self.userID = userID
            self.properties = properties
        }
    }

    enum IdentityState: Equatable, Sendable {
        case notIdentified
        case identified(Identity)
    }
}
