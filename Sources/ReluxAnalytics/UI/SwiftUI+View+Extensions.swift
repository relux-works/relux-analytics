import SwiftUI
import Relux

public extension View {
	func trackingAppearance(
		of view: Analytics.Event,
		data: Analytics.Data? = nil
	) -> some View  {
		self
			.onAppear {
                track(view.with(.init(rawValue: "open")), data: data)
			}
			.onDisappear {
                track(view.with(.init(rawValue: "close")), data: data)
			}
	}
	
	func track(
		_ event: Analytics.Event,
		data: Analytics.Data? = nil
	)  {
		Task(priority: .low) {
            await action {
				Analytics.SideEffect.track(event, data)
            }
		}
	}
}
