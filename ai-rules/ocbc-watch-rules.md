# OCBC Watch Rules

## Modular Boundaries
- `OCBCKit` remains a single library product.
- Features stay isolated and do not import each other.
- Shared types belong in `AppCore`.
- Shared visual components/assets belong in `DesignSystem`.

## Navigation
- Route via `Router.route(to:)` and `Destination`.
- Keep `navigationDestination` wiring in root composition.
- Feature screens should not own global navigation graphs.

## Screen Store Pattern
- One `@Observable`, `@MainActor` store per screen.
- Store owns `state: ScreenState<Value>`.
- Expose `task()` for initial load and `retryButtonTapped()` for retries.
- Keep mapping from service/cache models to UI models in store layer.

## SwiftUI Composition
- Keep every `Screen` body intentionally small; if body grows, extract immediately.
- One primary `View` per file by default.
- Split view pieces into explicit component files; avoid multiple sibling view types in a single file.
- Do not create decorative backdrop circles.
- Do not render per-screen titles unless explicitly requested.

## Platform/API
- Minimum deployment target is `26`.
- Use Liquid Glass APIs directly when needed.
