# AppMetrica Sample Aggregator

## Decision

The first concrete `ReluxAnalytics` sample aggregator uses AppMetrica.

## AppMetrica Project

- AppMetrica overview: https://appmetrica.yandex.com/overview?appId=6324763&period=week&group=day&currency=rub&accuracy=medium
- AppMetrica app id: `6324763`
- Sample API key: `YOUR_APPMETRICA_API_KEY`

## Integration Docs

- Official quick start: https://appmetrica.yandex.com/docs/en/sdk/ios/analytics/quick-start?tabs=defaultTabsGroup-v5q7vdkn_spm%2520in%2520xcode
- SPM repository: `https://github.com/appmetrica/appmetrica-sdk-ios`
- Mandatory product: `AppMetricaCore`
- Tuist/Xcode linker setting from docs: `OTHER_LDFLAGS = $(inherited) -ObjC`

## Persistent References

Keep these anchors in the repo so the sample can be rebuilt without relying on chat history.

- Project overview URL: https://appmetrica.yandex.com/overview?appId=6324763&period=week&group=day&currency=rub&accuracy=medium
- Project app id: `6324763`
- Sample API key: `YOUR_APPMETRICA_API_KEY`
- Integration guide: https://appmetrica.yandex.com/docs/en/sdk/ios/analytics/quick-start?tabs=defaultTabsGroup-v5q7vdkn_spm%2520in%2520xcode
- SPM package URL: `https://github.com/appmetrica/appmetrica-sdk-ios`
- App target product: `AppMetricaCore`
- Required linker flags: `$(inherited) -ObjC`

## Expected Sample Wiring

- The sample app depends on local `../sdk` product `ReluxAnalytics`.
- The sample app depends on AppMetrica via SPM.
- The sample app initializes AppMetrica with `AppMetricaConfiguration(apiKey:)` and `AppMetrica.activate(with:)`.
- The sample app provides an AppMetrica-backed `Analytics.Aggregator`.
- UI and flow code emit analytics through `Analytics.Effect`, not through direct AppMetrica SDK calls.

## Board

- Task: `TASK-260707-1jyo4h` (`sample-appmetrica-aggregator`)
