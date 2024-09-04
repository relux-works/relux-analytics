public extension Analytics {
	protocol LicenseKeyProviding: Sendable {
		var licenseKey: String { get async throws }
	}
}
