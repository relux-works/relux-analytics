# TASK-260707-2gvky6: repo-layout-sdk-and-sample

## Description
Restructure the relux-analytics repository into a repo root with sdk/ for the ReluxAnalytics Swift package and sample/ for a scaffolded iOS sample app that consumes the local SDK package. Do not create a separate sibling sample repo unless the architecture changes again; the current repo should contain both SDK and sample.

## Scope
(define task scope)

## Acceptance Criteria
- Existing ReluxAnalytics Swift package files live under sdk/.
- Repository root keeps git, task board, README, license, and shared docs.
- sample/ is created through ios-app-manager scaffold, not handwritten Tuist files.
- sample app references the local sdk package path where supported by scaffold configuration or documented follow-up if scaffold cannot express it.
- Root .gitignore covers SwiftPM, Tuist, Xcode, and board temp outputs without hiding source files.
