public extension Analytics {
	protocol IUserIdentityProvider: Sendable {
		var userIdentity: String { get async }
	}
}
