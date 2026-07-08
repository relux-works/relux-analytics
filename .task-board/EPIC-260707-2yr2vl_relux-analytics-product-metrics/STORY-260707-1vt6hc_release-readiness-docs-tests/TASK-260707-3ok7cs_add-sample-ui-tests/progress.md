## Status
done

## Assigned To
codex

## Created
2026-07-07T14:57:17Z

## Last Update
2026-07-08T07:52:30Z

## Blocked By
- (none)

## Blocks
- (none)

## Checklist
(empty)

## Notes
Updated sample metric surface before UI tests: bootstrap start no longer identifies, and the app now exposes explicit anonymous/identified instant and continuous controls with stable accessibility identifiers and ANALYTICS_TEST_RUN_ID event parameters.
Scaffolded ReluxAnalyticsSampleUITests and replaced the starter with a Page Object XCUITest flow covering reset identity, anonymous instant, anonymous continuous start/stop, identify, identified instant, and identified continuous start/stop. Added ScreenshotKit/UITestKit dependencies.
UI test target build-for-testing succeeded with ScreenshotKit/UITestKit dependencies. Next step: run the test on iOS Simulator, extract screenshots, and inspect them.
First UI test run exposed an AppMetrica startup crash: AMAAppGroupIdentifierProvider called NSBundle.applicationBundle from an ObjC category that was not loaded. Added -ObjC linker flags to the sample app/UI test final links and AppMetricaPlatform package target settings.
UI test passed after the -ObjC fix. xcodebuild log: .temp/xcodebuild-sample-ui-tests-02.log. Result bundle: .temp/ReluxAnalyticsSampleUITests-02.xcresult. Actual in-app run_id printed by the test: ui-1783436923.
Latest UI test verification passed after contract fix: xcodebuild test on iPhone 17 / iOS 26.5 succeeded. Result bundle .temp/ReluxAnalyticsSampleUITests-contract-03.xcresult, log .temp/xcodebuild-sample-ui-tests-contract-03.log, screenshots extracted to .temp/screenshots-relux-analytics-sample-contract-03 and visually inspected. Fresh run_id ui-1783437986.
Inline reviewer accepted UI test task. Latest passing xcodebuild UI test and visually inspected screenshots are recorded in task notes.

## Precondition Resources
(none)

## Outcome Resources
(none)
