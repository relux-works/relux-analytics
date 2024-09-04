public extension Analytics {
	enum ServiceError: Error, Sendable {
        case failedToSetup(cause: Error)
        case failedToTrack(event: Analytics.Event, action: Analytics.Action, cause: Error)
    }
}
