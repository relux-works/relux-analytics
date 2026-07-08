# TASK-260707-x4xhma: write-relux-analytics-readme

## Description
Write the public ReluxAnalytics README covering architecture, package layout, usage, sample setup, verification commands, and tooling.

## Scope
Write and maintain the root ReluxAnalytics README for the repo layout introduced by the major-version work: sdk/ Swift package plus sample/ iOS app. The README must explain the architecture from high level to internals, how to wire aggregators, how Relux effects/Saga/Module are used, how SwiftUI helpers fit, how the AppMetrica sample is configured, and how to run verification tools.

## Acceptance Criteria
- README.md exists at the relux-analytics repo root and is written in English.
- README documents repo layout: sdk/ and sample/.
- README documents abstraction levels: analytics domain events, continuous event manager, service/aggregator boundary, Relux integration, SwiftUI helpers, and sample AppMetrica adapter.
- README includes AppMetrica sample anchors: overview URL, app id, sample API key, docs URL, SPM package URL, AppMetricaCore product, and -ObjC linker flag.
- README includes exact commands for swift test, package resolve, Tuist install/generate, xcodebuild sample build, and task-board usage.
- README states where generated outputs and logs belong, including .temp/ and ignored Tuist/Xcode build artifacts.
- README avoids claiming live AppMetrica ingestion until the sample has been manually verified in the AppMetrica dashboard.
