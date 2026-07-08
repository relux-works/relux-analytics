## Status
done

## Assigned To
codex

## Created
2026-07-07T14:11:30Z

## Last Update
2026-07-08T08:00:41Z

## Blocked By
- (none)

## Blocks
- (none)

## Checklist
(empty)

## Notes
Scaffold gap: ios-app-manager dep add-external supports remote Git packages but not sibling local Swift packages such as ../sdk. The sample needs a scoped manifest patch to consume the local SDK until the scaffold tool grows local external package support.
Implemented monorepo layout: sdk/ Swift package, integrations/appmetrica Swift package, sample/ Tuist iOS app, plus root board/spec configuration. sample local package wiring required a scoped manifest patch because scaffold cannot express sibling local package dependencies yet.

## Precondition Resources
(none)

## Outcome Resources
(none)
