import Foundation

public extension Analytics {
	protocol IUserIdentityProvider: Sendable {
		var userIdentity: UUID { get async }
	}
}
