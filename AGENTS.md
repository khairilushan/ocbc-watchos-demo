# Agent Guide

## Purpose
Agents act as senior Swift collaborators for this repository. Keep responses concise, clarify ambiguity before coding, and follow the rule index below.

## Rule Index
- @ai-rules/rule-loading.md — load this first to select task-specific rules.
- @ai-rules/ocbc-watch-rules.md — repository-specific architecture and UI rules learned in this project.

## Skill Mapping
- New/updated SwiftUI screen UI (layout, composition, modern API): `swiftui-expert-skill`
- Liquid Glass styling/adoption/refactor: `swiftui-liquid-glass`
- Introduce/refactor screen model/store (`@Observable` model, UI state): `pfw-observable-models`
- Add/modify Swift package targets/products/dependencies/resources: `pfw-spm`
- Add tests for store logic/state transitions/general Swift tests: `pfw-testing`
- Add snapshot tests (if we re-enable later): `pfw-snapshot-testing`
- Concurrency refactor (`async/await`, actor isolation, Sendable issues): `swift-concurrency`
- Deep architecture/codebase investigation before big changes: `rp-investigate`
- End-to-end build/implement flow with curated context: `rp-build`
- Refactor for module/code organization quality: `rp-refactor`
- Formal code review workflow: `rp-review`
- Find/install new skills when capability is missing: `find-skills`, then `skill-installer`

## Repository Overview
- Product: watchOS banking demo.
- App target: `OCBC Watch App` (entry point in `OCBCApp.swift`).
- Shared package: `OCBCKit` (single exported library product, internally modular targets).
- Root composition view: `OCBCRootView` in `OCBCKit`.

## Commands
- `cd OCBCKit && swift build` — build package targets.
- `cd OCBCKit && swift test` — run package tests.
- `xcodebuild -project OCBC.xcodeproj -scheme "OCBC Watch App" -destination "platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)" build` — build app from CLI.

## Code Style
- Use modern SwiftUI APIs.
- Never ship a large SwiftUI `body`; break complex layouts into smaller components.
- Default to one primary `View` type per file.
- Keep each SwiftUI file focused and composable.
- Avoid helper abstractions that hide straightforward UI intent.
- Keep comments minimal and only where logic is non-obvious.

## Architecture & Patterns
- `OCBCKit` exports one library product, composed from multiple feature targets.
- Feature isolation is strict: features do not import sibling feature targets.
- Cross-feature navigation is centralized:
  - `AppCore.Destination` defines routes.
  - `Router` is injected from root via environment.
  - Root handles `navigationDestination`.
- Each feature has:
  - `Screen` view
  - `Components/`
  - `Models/`
  - `Stores/`
- One screen store per feature (`@Observable`, `@MainActor`) bridges service/cache layer to UI model.
- Shared screen state is generic in `AppCore`:
  - `ScreenState<Value> = .loading | .success(Value) | .failure(String)`

## Key Integration Points
- Core shared module: `OCBCKit/Sources/AppCore`.
- Reusable UI/assets module: `OCBCKit/Sources/DesignSystem`.
- Features: `HomeFeature`, `BalanceFeature`, `QrisFeature`, `FundTransferFeature`, `PaymentFeature`, `PinFeature`, `WithdrawalFeature`.
- Feature core modules: `BalanceCore`, `QrisCore`, `WithdrawalCore`.
- QR assets are in `QrisFeature` resources and shared assets/helpers live in `DesignSystem`.

## Workflow
- Before major refactors: inspect target dependencies in `Package.swift`.
- Keep feature boundaries clean; route through `Destination` + `Router`.
- If introducing a reusable component, place it in `DesignSystem`.
- Update `README.md` and `AGENTS.md` when architecture/patterns change.

## Testing
- Minimum: run `swift build` after structural changes.
- Prefer `swift test` for package verification before commit.
- Add tests around store state transitions and mapping as features mature.

## Environment
- Deployment targets in package are set to platform version `26`.
- Liquid Glass APIs are allowed directly (no older-platform fallback needed in this repo).

## Special Notes
- UI decisions from this session:
  - Remove decorative circular backdrop on screens.
  - Remove screen titles in feature screens.
  - Keep SwiftUI `body` minimal and split view pieces into separate component files.
  - Prefer one view per file instead of defining multiple sibling views in one file.
- If there is no `upstream` git remote, use `origin`.
