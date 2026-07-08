# Membrana Metrics And Localization Pattern Research

Task: `TASK-260708-47uhhz`

Source inspected: `/Users/alexis/src/membrana`.

## Product Metrics

Membrana separates analytics into two layers.

The reusable analytics package owns the transport-shaped event model:

- `/Users/alexis/src/membrana/packages/ios-klasta-analytics/Sources/KlastaAnalytics/Model/AnalyticsEvent.swift:1`
- `/Users/alexis/src/membrana/packages/ios-klasta-analytics/Sources/KlastaAnalytics/Helper/AnalyticsEvent+Helpers.swift:3`
- `/Users/alexis/src/membrana/packages/ios-klasta-analytics/Sources/KlastaAnalytics/Helper/AnalyticsEvent+View.swift:6`

`KlastaAnalytics.Business.Model.AnalyticsEvent` contains raw collector fields such as `eventType`, `screenName`, `eventCategory`, `eventLabel`, `eventContent`, `eventContext`, `interactionType`, `action`, and `actionTarget`. Helper factories such as `screenAppearance`, `tapButton`, and `tapElement` encode common PM shapes once, outside feature UI.

Feature modules then expose their own typed metric tree in `Module+Analytics.swift`:

- `/Users/alexis/src/membrana/app/Shared/Sources/Auth/Auth+Analytics.swift:4`
- `/Users/alexis/src/membrana/app/Application/Sources/Modules/Profiles/Profiles+Analytics.swift:3`

The feature tree mirrors product/module structure:

- Root is `extension <Module> { enum Analytics { ... } }`.
- `typealias AnalyticsEvent = KlastaAnalytics.Business.Model.AnalyticsEvent` keeps call sites short.
- A nested `Screen` enum centralizes screen names when a module has many surfaces.
- Nested enums represent screens, flows, widgets, popups, or product areas.
- Static `let` values represent fixed events.
- Static `func` factories represent events with runtime context, for example selected profile or status name.
- UI and business code calls typed events such as `Profiles.Analytics.CallManagement.tapHint`, not raw `AnalyticsEvent(...)`.
- View helpers accept typed events directly: `.trackAppearance(event:)`, `.onTapTrackEvent(_:)`, and `trackEvent(_:)`.

The AppMetrica/Yandex conversion stays in the analytics package:

- `/Users/alexis/src/membrana/packages/ios-klasta-analytics/Sources/KlastaAnalytics/Model/YandexMetricaEvent.swift:15`
- `/Users/alexis/src/membrana/packages/ios-klasta-analytics/Sources/KlastaAnalytics/Business/KlastaAnalytics+Saga.swift:13`

Resulting pattern:

```swift
extension Profiles {
    enum Analytics {
        typealias Event = ProductAnalytics.Event

        enum Screen: String {
            case profileSelector = "/profiles"
            var name: String { rawValue }
        }

        enum ProfileSelector {
            private static let screenName = Screen.profileSelector.name

            static let screenAppear = Event.screenAppearance(screenName: screenName)

            static func selectProfile(_ profile: String) -> Event {
                Event.tapElement(
                    screenName: screenName,
                    eventCategory: "profiles",
                    eventLabel: profile.analyticsLabel,
                    eventContent: "status"
                )
            }
        }
    }
}
```

Call sites should stay declarative:

```swift
ProfileSelectorView()
    .trackAppearance(event: Profiles.Analytics.ProfileSelector.screenAppear)

Button {
    trackEvent(Profiles.Analytics.ProfileSelector.selectProfile(profile.name))
} label: {
    Text(title)
}
```

## Localization

Membrana uses a typed `loc` tree matching modules and sub-surfaces:

- `/Users/alexis/src/membrana/app/Application/Sources/Modules/App/App+Localization.swift:3`
- `/Users/alexis/src/membrana/app/Application/Sources/Modules/SafeNetwork/SafeNetwork+Localization.swift:3`
- `/Users/alexis/src/membrana/app/Application/Sources/Modules/Profiles/Profiles+Localization.swift:5`

Pattern:

- Root `enum loc {}` is defined once.
- Each module extends `loc` with a nested namespace, for example `loc.profiles`.
- Each module file keeps its own table name close to the namespace.
- Nested enums mirror product UI hierarchy: selector, notification, routing, alert, etc.
- Static `let` values represent fixed strings.
- Static `func` values represent interpolated/pluralized strings.
- UI/business code uses typed accessors such as `loc.profiles.management.header`, not raw localization keys.

Reusable shape:

```swift
enum loc {}

extension loc {
    enum sample {
        private static let table = "LocalizableSample"

        enum main {
            static let title = String(
                localized: "loc.sample.main.title",
                table: table,
                bundle: .module,
                comment: ""
            )

            static func sentCount(_ count: Int) -> String {
                String(
                    localized: "loc.sample.main.sent_count(count: \(count))",
                    table: table,
                    bundle: .module,
                    comment: ""
                )
            }
        }
    }
}
```

## Guidance For ReluxAnalytics Sample

For the ReluxAnalytics sample, add a sample-owned typed metrics namespace before touching UI:

```swift
extension ReluxAnalyticsSample {
    enum Metrics {
        enum Main {
            static let screenAppeared = Analytics.InstantEvent(...)
            static func instantTapped(count: Int) -> Analytics.InstantEvent { ... }
            static func sessionStarted(spanID: Analytics.SpanID) -> Analytics.ContinuousStartEvent { ... }
            static func sessionStopped(spanID: Analytics.SpanID) -> Analytics.ContinuousStopEvent { ... }
        }
    }
}
```

Then UI should dispatch:

```swift
Analytics.Effect.track(.instant(ReluxAnalyticsSample.Metrics.Main.instantTapped(count: currentCount)))
Analytics.Effect.track(.continuous(.start(ReluxAnalyticsSample.Metrics.Main.sessionStarted(spanID: spanID))))
```

Do not keep event names, finish event names, stale timeouts, or stable parameter keys inline in SwiftUI button bodies.
