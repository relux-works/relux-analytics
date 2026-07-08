import AppMetricaCore
import Foundation
import ReluxAnalytics

public extension Analytics {
    actor AppMetricaService: Service {
        public enum EventsBufferFlushPolicy: Sendable {
            case automatic
            case afterEveryReport
        }

        private let service: DefaultService

        public var currentIdentityState: IdentityState {
            get async {
                await service.currentIdentityState
            }
        }

        public init(
            apiKey: String,
            continuousEventManager: any ContinuousEventManager = DefaultContinuousEventManager(),
            eventsBufferFlushPolicy: EventsBufferFlushPolicy = .automatic,
            contextProviders: [any ContextProvider] = []
        ) {
            self.init(
                apiKey: apiKey,
                client: LiveAppMetricaClient(),
                continuousEventManager: continuousEventManager,
                eventsBufferFlushPolicy: eventsBufferFlushPolicy,
                contextProviders: contextProviders
            )
        }

        init(
            apiKey: String,
            client: any AppMetricaClient,
            continuousEventManager: any ContinuousEventManager = DefaultContinuousEventManager(),
            eventsBufferFlushPolicy: EventsBufferFlushPolicy = .automatic,
            contextProviders: [any ContextProvider] = []
        ) {
            self.service = DefaultService(
                aggregators: [
                    AppMetricaAggregator(
                        apiKey: apiKey,
                        client: client,
                        eventsBufferFlushPolicy: eventsBufferFlushPolicy
                    )
                ],
                continuousEventManager: continuousEventManager,
                contextProviders: contextProviders
            )
        }

        public func start() async {
            await service.start()
        }

        public func identify(_ identity: Identity) async {
            await service.identify(identity)
        }

        public func resetIdentity() async {
            await service.resetIdentity()
        }

        public func track(_ event: Event) async {
            await service.track(event)
        }
    }
}

extension Analytics {
    typealias AppMetricaParameters = [String: AppMetricaValue]

    enum AppMetricaValue: Equatable, Sendable {
        case string(String)
        case int(Int)
        case double(Double)
        case bool(Bool)

        var rawValue: Any {
            switch self {
            case let .string(value):
                value
            case let .int(value):
                value
            case let .double(value):
                value
            case let .bool(value):
                value
            }
        }
    }

    protocol AppMetricaClient: Sendable {
        func activate(apiKey: String) async -> Bool
        func setUserProfileID(_ userID: String?) async
        func reportEvent(name: String, parameters: AppMetricaParameters) async
        func sendEventsBuffer() async
    }
}

private struct LiveAppMetricaClient: Analytics.AppMetricaClient {
    func activate(apiKey: String) async -> Bool {
        guard let configuration = AppMetricaConfiguration(apiKey: apiKey) else { return false }

        await MainActor.run {
            AppMetrica.activate(with: configuration)
        }
        return true
    }

    func setUserProfileID(_ userID: String?) async {
        await MainActor.run {
            AppMetrica.userProfileID = userID
        }
    }

    func reportEvent(
        name: String,
        parameters: Analytics.AppMetricaParameters
    ) async {
        await MainActor.run {
            AppMetrica.reportEvent(
                name: name,
                parameters: parameters.rawAppMetricaParameters,
                onFailure: nil
            )
        }
    }

    func sendEventsBuffer() async {
        await MainActor.run {
            AppMetrica.sendEventsBuffer()
        }
    }
}

private actor AppMetricaAggregator: Analytics.Aggregator {
    private let apiKey: String
    private let client: any Analytics.AppMetricaClient
    private let eventsBufferFlushPolicy: Analytics.AppMetricaService.EventsBufferFlushPolicy
    private var activated = false

    init(
        apiKey: String,
        client: any Analytics.AppMetricaClient,
        eventsBufferFlushPolicy: Analytics.AppMetricaService.EventsBufferFlushPolicy
    ) {
        self.apiKey = apiKey
        self.client = client
        self.eventsBufferFlushPolicy = eventsBufferFlushPolicy
    }

    func start() async {
        _ = await activateIfNeeded()
    }

    private func activateIfNeeded() async -> Bool {
        guard activated == false else { return true }
        activated = await client.activate(apiKey: apiKey)
        return activated
    }

    func identify(_ identity: Analytics.Identity) async {
        guard await activateIfNeeded() else { return }

        await client.setUserProfileID(identity.userID)
        await report(
            name: "analytics_identified",
            parameters: identity.properties
        )
    }

    func resetIdentity() async {
        await client.setUserProfileID(nil)
    }

    func track(_ event: Analytics.CollectorEvent) async {
        guard await activateIfNeeded() else { return }

        switch event {
        case let .instant(event):
            await report(name: event.name, parameters: event.collectorParameters)
        case let .continuousAggregate(aggregate):
            await report(name: aggregate.finishEventName, parameters: aggregate.collectorParameters)
        }
    }

    private func report(
        name: String,
        parameters: Analytics.Parameters
    ) async {
        guard activated else { return }

        await client.reportEvent(name: name, parameters: parameters.appMetricaParameters)

        if eventsBufferFlushPolicy == .afterEveryReport {
            await client.sendEventsBuffer()
        }
    }
}

extension Analytics.Parameters {
    var appMetricaParameters: Analytics.AppMetricaParameters {
        reduce(into: Analytics.AppMetricaParameters()) { result, entry in
            result[entry.key] = entry.value.appMetricaValue
        }
    }
}

private extension Analytics.AppMetricaParameters {
    var rawAppMetricaParameters: [AnyHashable: Any] {
        reduce(into: [AnyHashable: Any]()) { result, entry in
            result[entry.key] = entry.value.rawValue
        }
    }
}

private extension Analytics.Value {
    var appMetricaValue: Analytics.AppMetricaValue {
        switch self {
        case let .string(value):
            .string(value)
        case let .int(value):
            .int(value)
        case let .double(value):
            .double(value)
        case let .bool(value):
            .bool(value)
        }
    }
}
