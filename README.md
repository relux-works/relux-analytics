# relux-analytics

Relux module for product analytics. Analytics events are ordinary
[Relux](https://github.com/relux-works/swift-relux) actions: views declare events,
a saga routes them through side effects, and vendor adapters deliver them. The core
stays vendor agnostic; pair it with an adapter such as
[relux-analytics-amplitude](https://github.com/relux-works/relux-analytics-amplitude).

## Installation (Swift Package Manager)

```swift
.package(url: "https://github.com/relux-works/relux-analytics.git", from: "1.0.0")
```

```swift
.product(name: "ReluxAnalytics", package: "relux-analytics")
```

## Usage

Register the module in your Relux runtime, then emit events from views or business
logic as actions. SwiftUI helpers cover screen-view tracking. A working setup is shown
in [relux-analytics-sample](https://github.com/relux-works/relux-analytics-sample).

<!-- relux-ecosystem:start -->

## About Relux Works

This project is part of the open-source ecosystem of
[Relux Works](https://relux.works), an AI-native software development studio.
We build fixed-price MVPs, rescue vibe-coded apps, run local AI inference, and
train teams to work with coding agents. Much of the infrastructure behind that
work is open source.

- Full catalog: [relux.works/en/open-source](https://relux.works/en/open-source/)
- Agentic enablement: [agent harnesses & team training](https://relux.works/en/agentic-enablement/)
- Hire us the agent-native way: point your assistant at `https://api.relux.works/mcp`
- Contact: ivan@relux.works

<!-- relux-ecosystem:end -->

## License

See [LICENSE](LICENSE).
