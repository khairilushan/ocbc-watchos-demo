# OCBC Watch App (Modular SwiftUI + SPM)

A watchOS banking app prototype structured screen-by-screen using a modular Swift Package (`OCBCKit`).

## Current Status

Implemented so far:
- `Home` screen
- `Balance` screen
- `QRIS` screen
- `Fund Transfer` screen
- `Payment & Purchase` screen
- Root navigation and routing
- Shared `ScreenStore` per feature with `loading/success/failure` state
- `DesignSystem` target for shared UI and assets

The watch app entry point renders `OCBCRootView` directly.

## Tech Stack

- SwiftUI
- Swift Package Manager
- Observation (`@Observable`) for routing and screen stores
- Liquid Glass API (minimum deployment target set to 26.0)

## Project Structure

```text
OCBC/
├── OCBC Watch App/                 # App target
│   └── OCBCApp.swift               # @main, launches OCBCRootView
└── OCBCKit/                        # Local Swift package
    ├── Package.swift
    └── Sources/
        ├── OCBCKit/                # Public library surface
        │   └── OCBCRootView.swift
        ├── AppCore/                # Shared app primitives
        │   ├── Destination.swift
        │   ├── Router.swift
        │   ├── RouterEnvironment.swift
        │   └── ScreenState.swift
        ├── DesignSystem/           # Shared reusable UI and assets
        │   ├── OCBCLoadingView.swift
        │   ├── OCBCFailureView.swift
        │   ├── Image+DesignSystem.swift
        │   └── Resources/
        ├── HomeFeature/
        │   ├── HomeScreen.swift
        │   ├── Components/
        │   ├── Models/
        │   └── Stores/
        ├── BalanceFeature/
        │   ├── BalanceScreen.swift
        │   ├── Components/
        │   ├── Models/
        │   └── Stores/
        ├── QrisFeature/
        │   ├── QrisScreen.swift
        │   ├── Components/
        │   ├── Models/
        │   ├── Stores/
        │   └── Resources/
        │       └── Assets.xcassets
        ├── FundTransferFeature/
        │   └── Stores/
        └── PaymentFeature/
            └── Stores/
```

## Architecture

### Architecture Diagram (Box)

```text
+------------------------+         +------------------------------+
| OCBC Watch App target  | ----->  | OCBCKit (library product)   |
+------------------------+         +------------------------------+
                                         |
                                         v
                               +----------------------+
                               | OCBCKit target       |
                               +----------------------+
                                |    |    |    |    |    |
                                v    v    v    v    v    v
                         +---------+ +------------+ +-----------+ +--------------+ +------------+ +-------------------+ +---------------+
                         | AppCore | |DesignSystem| |HomeFeature| |BalanceFeature| |QrisFeature | |FundTransferFeature| |PaymentFeature|
                         +---------+ +------------+ +-----------+ +--------------+ +------------+ +-------------------+ +---------------+
                             ^            ^               |               |                  |                     |
                             |            |               |               |                  |                     |
                             +------------+---------------+---------------+------------------+---------------------+
                                     each feature target depends on AppCore + DesignSystem
```

### 1) Single Library Product, Multiple Feature Targets

`Package.swift` exposes one product:
- `OCBCKit`

Internally, it composes multiple targets:
- `AppCore`
- `DesignSystem`
- `HomeFeature`
- `BalanceFeature`
- `QrisFeature`
- `FundTransferFeature`
- `PaymentFeature`
- `OCBCKit` (root composition target)

Each feature target is isolated and does not import sibling feature targets.

### 2) Router-Driven Navigation from Root

Navigation is centralized in `OCBCRootView` with `NavigationStack` + `navigationDestination(for:)`.

- `Destination` enum defines all reachable screens.
- `Router` owns a `path` array and exposes:
  - `route(to:)`
  - `popToRoot()`
- `Router` is injected via SwiftUI environment from root.

This keeps screen targets decoupled while still supporting app-wide navigation.

### 3) ScreenStore Pattern (`@Observable`)

Each feature owns one store (e.g. `HomeScreenStore`) that bridges service/cache data into UI models and publishes screen state:

- `state: ScreenState<Value>`
- `task() async`
- `retryButtonTapped() async`

`ScreenState<Value>` lives in `AppCore` and is shared by all features:

- `.loading`
- `.success(Value)`
- `.failure(String)`

### 4) View Composition Convention

Each feature is split into:
- `Screen` file (simple body composition)
- `Components/` (small reusable views)
- `Models/` (feature-specific types)
- `Stores/` (feature state + mapping logic)

Goal: keep each SwiftUI `body` focused and minimal.

## QRIS Assets

`QrisFeature` uses asset catalog resources (`Assets.xcassets`) inside the target resources.

Current asset names used in code:
- `icon.qris.logo`
- `image.sample.qr`

## Build & Run

### Run the watch app in Xcode

1. Open `OCBC.xcodeproj`
2. Select `OCBC Watch App` scheme
3. Run on a watchOS simulator

### Build the package from terminal

```bash
cd OCBCKit
swift build
```

## Roadmap (next)

- Add real repository/service dependencies into each `ScreenStore`
- Add feature-level tests for store mapping and state transitions
- Expand design tokens for spacing, typography, and color roles
