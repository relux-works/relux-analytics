import Relux
import SwiftUI

public extension View {
    func trackAnalyticsAppearance(
        _ event: Analytics.InstantEvent,
        condition: @escaping @Sendable () -> Bool = { true }
    ) -> some View {
        onAppear {
            trackAnalytics(event, condition: condition)
        }
    }

    func trackAnalyticsTap(
        _ event: Analytics.InstantEvent,
        condition: @escaping @Sendable () -> Bool = { true }
    ) -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                trackAnalytics(event, condition: condition)
            }
        )
    }

    func trackAnalytics(
        _ event: Analytics.InstantEvent,
        condition: @escaping @Sendable () -> Bool = { true }
    ) {
        guard condition() else { return }

        performAsync {
            Analytics.Effect.track(.instant(event))
        }
    }

    func trackAnalytics(
        _ event: Analytics.ContinuousEvent,
        condition: @escaping @Sendable () -> Bool = { true }
    ) {
        guard condition() else { return }

        performAsync {
            Analytics.Effect.track(.continuous(event))
        }
    }
}
