# TASK-260707-fj844s: upgrade-package-to-swift-6-2

## Description
Upgrade the existing relux-analytics Swift package to swift-tools-version 6.2, strict Swift 6 settings, and the current Relux dependency baseline before porting the improved analytics API. Update swift-relux to the current compatible package version used by nearby Relux packages.

## Scope
(define task scope)

## Acceptance Criteria
- Package.swift uses swift-tools-version 6.2.
- Package enables strict Swift 6/upcoming feature settings matching current Relux packages.
- swift-relux dependency is updated from the old 9.0.0 baseline to the current compatible baseline.
- Package resolves and builds with swift build/test before analytics API changes continue.
