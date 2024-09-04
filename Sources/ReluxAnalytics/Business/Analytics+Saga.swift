import Foundation
import Relux

extension Analytics {
    public actor Saga: Relux.Saga {
        private let analyticsService: IAnalyticsService
        private let userIdentityProvider: IUserIdentityProvider

        public init(
                analyticsService: IAnalyticsService,
				userIdentityProvider: IUserIdentityProvider
        ) {
            self.analyticsService = analyticsService
            self.userIdentityProvider = userIdentityProvider
        }

        public func apply(_ effect: Relux.Effect) async {
			switch effect as? Analytics.SideEffect {
				case .none:
					break
				case .setup:
					await setup()
                case let .setUserProperties(userProperties):
                    await setUserProperties(userProperties)
				case let .track(event, data):
					await track(event, data)
			}
		}

        private func setup() async {
			do {
				try await analyticsService.setup(userId: userIdentityProvider.userIdentity.uuidString)
			}
			catch {
				
			}
        }
        
        private func setUserProperties(_ userProperties: Analytics.Data) async {
            do {
                try await analyticsService.setUserProperties(userProperties)
            }
            catch {
                
            }
        }

        private func track(_ event: Analytics.Event, _ data: Analytics.Data?) async {
			do {
				try await analyticsService.track(event, data)
			}
			catch {
				
			}
        }
    }
}
