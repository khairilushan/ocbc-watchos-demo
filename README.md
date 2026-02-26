# OCBC Watch App (Modular SwiftUI + SPM)

A watchOS banking app prototype structured screen-by-screen using a modular Swift Package (`OCBCKit`).

## Current Status

Implemented so far:
- `Home` screen
- `Balance` screen
- `QRIS` screen
- Root navigation and routing
- Asset-catalog based QRIS resources

The watch app entry point renders `OCBCRootView` directly.

## Tech Stack

- SwiftUI
- Swift Package Manager
- Observation (`@Observable`) for routing state
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
        │   └── RouterEnvironment.swift
        ├── HomeFeature/
        │   ├── HomeScreen.swift
        │   ├── Components/
        │   └── Models/
        ├── BalanceFeature/
        │   ├── BalanceScreen.swift
        │   ├── Components/
        │   └── Models/
        ├── QrisFeature/
        │   ├── QrisScreen.swift
        │   ├── Components/
        │   ├── Models/
        │   └── Resources/
        │       └── Assets.xcassets
        ├── FundTransferFeature/
        └── PaymentFeature/
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
                         +---------+ +-----------+ +--------------+ +------------+ +-------------------+ +---------------+
                         | AppCore | |HomeFeature| |BalanceFeature| |QrisFeature | |FundTransferFeature| |PaymentFeature|
                         +---------+ +-----------+ +--------------+ +------------+ +-------------------+ +---------------+
                             ^            |               |               |                  |                     |
                             |            |               |               |                  |                     |
                             +------------+---------------+---------------+------------------+---------------------+
                                              each feature target depends on AppCore
```

### 1) Single Library Product, Multiple Feature Targets

`Package.swift` exposes one product:
- `OCBCKit`

Internally, it composes multiple targets:
- `AppCore`
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

### 3) View Composition Convention

Each feature is split into:
- `Screen` file (simple body composition)
- `Components/` (small reusable views)
- `Models/` (feature-specific types)

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

- Implement `Fund Transfer` screen
- Implement `Payment & Purchase` screen
- Add design tokens (spacing, typography, color roles)
- Add feature-level tests for models and navigation behavior
