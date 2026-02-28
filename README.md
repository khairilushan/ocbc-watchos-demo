# OCBC Watch App (Modular SwiftUI + SPM)

A watchOS banking app prototype structured screen-by-screen using a modular Swift Package (`OCBCKit`).

## Current Status

Implemented so far:
- `Home` screen
- `Balance` screen
- `QRIS` screen
- `QRIS` flow:
  - fetch primary account
  - generate QR payload
  - custom amount via keypad sheet (`Generate QR`)
- `Fund Transfer` flow:
  - recipient list with pagination
  - amount input screen (recipient + source funds, amount/message/transaction time)
  - validation request (`POST /fundtransfer/v5/validate`) on Continue
  - route to `PinFeature` on successful validation
- `Payment & Purchase` screen
- Reusable `PinFeature` with custom digit keypad (0-9 + delete)
- `Withdrawal` flow:
  - load source of funds + amount configuration
  - validate request
  - route to `PinFeature`
  - acknowledge/verification step and result screen
- Root navigation and routing
- Shared `ScreenStore` pattern per feature with `loading/success/failure` state
- `DesignSystem` target for shared UI and assets
- Shared amount keypad with compact delete control and aligned layout
- Primary action buttons standardized to red tint (`Color.red.opacity(0.9)`)

The watch app entry point renders `OCBCRootView` directly.

## Tech Stack

- SwiftUI
- Swift Package Manager
- Observation (`@Observable`) for routing and screen stores
- Point-Free `Dependencies` for dependency injection
- Point-Free `CasePaths` for ergonomic enum assertions
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
        │   ├── FundTransferRecipientScreen.swift
        │   ├── FundTransferAmountInputScreen.swift
        │   ├── Components/
        │   ├── Models/
        │   └── Stores/
        ├── PinFeature/
        │   ├── PinInputScreen.swift
        │   ├── Components/
        │   ├── Models/
        │   └── Stores/
        ├── WithdrawalFeature/
        │   ├── WithdrawalScreen.swift
        │   ├── WithdrawalVerificationScreen.swift
        │   ├── Components/
        │   ├── Models/
        │   └── Stores/
        └── PaymentFeature/
            ├── PaymentView.swift
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
                         +---------+ +------------+ +-----------+ +--------------+ +------------+ +-------------------+ +---------------+ +----------+ +-----------------+
                         | AppCore | |DesignSystem| |HomeFeature| |BalanceFeature| |QrisFeature | |FundTransferFeature| |PaymentFeature| |PinFeature| |WithdrawalFeature|
                         +---------+ +------------+ +-----------+ +--------------+ +------------+ +-------------------+ +---------------+ +----------+ +-----------------+
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
- `Networking`
- `BalanceCore`
- `QrisCore`
- `FundTransferCore`
- `PinCore`
- `WithdrawalCore`
- `HomeFeature`
- `BalanceFeature`
- `QrisFeature`
- `FundTransferFeature`
- `PaymentFeature`
- `PinFeature`
- `WithdrawalFeature`
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

## Networking

`Networking` is a reusable pipeline target for HTTP calls.  
`BalanceCore` is the first feature-core target that uses it via `BalanceClient`.

### Pipeline Components

- `Endpoint<Response>`: declares `path`, `method`, optional query/body/headers, and typed response.
- `RequestBuilder`: builds `URLRequest` from endpoint + `NetworkingConfig`.
- `APIClient`: executes endpoint, applies headers, validates status code, decodes response.
- `RequestHeaderProvider`: composable header layers (static headers, session, bearer auth, signature).
- `HTTPClient`: transport abstraction (`URLSessionHTTPClient` for live, spy/mock for tests).

### How To Add A New Endpoint

1. Create endpoint type in a feature-core target (example: `BalanceCore/Endpoints`):
   - Conform to `Endpoint`
   - Set `path` and `method`
   - Define `Response` model

2. Create response models in that feature-core target (example: `BalanceCore/Models`):
   - Map backend JSON shape with `CodingKeys`
   - Keep transport models separate from UI models

3. Add/extend feature client in feature-core target (example: `BalanceCore/Services/BalanceClient.swift`):
   - Add a closure function on the client (example: `fetchTotalBalances`)
   - Implement `.live(apiClient:)` to call `apiClient.execute(NewEndpoint())`
   - Map endpoint response to feature-core domain model inside the live client

4. Consume feature-core service in feature store:
   - Inject client into `ScreenStore` via `@Dependency`
   - Map feature-core domain model to screen UI model

5. Test the pipeline:
   - Use `SpyHTTPClient` + fixed nonce/timestamp/token/session/signer providers
   - Assert request path/headers and decoded/mapped output
   - Override feature client dependency in store tests

### Existing Example

- Endpoint: `/dashboard/inquiry-balance-total`
- Target ownership:
  - Endpoint + decoding + feature client: `BalanceCore` (`BalanceClient`)
  - UI mapping/state: `BalanceFeature` (`BalanceScreenStore`)

Additional implemented examples:
- `QrisCore`
  - `GET /qris/account/primary`
  - `POST /qris/v2/generate`
- `WithdrawalCore`
  - source of funds, amount config, validation, PIN verify, acknowledgement
- `FundTransferCore`
  - `POST /recipient/v5/transfer`
  - `POST /fundtransfer/v5/validate`

### Reusable Preview/Test Networking Setup

`AppCore` provides reusable preview providers and client factory:

- `PreviewNetworkingValues.config(...)`
- `PreviewNetworkingValues.apiClient(...)`
- `PreviewSessionProvider`
- `PreviewAccessTokenProvider`
- `PreviewRequestSigner`

## QRIS Assets

`QrisFeature` uses asset catalog resources (`Assets.xcassets`) inside the target resources.

Current asset names used in code:
- `icon.qris.logo`
- `image.sample.qr`

## Notes

- Main CTA buttons use a red-tinted prominent style for consistency.
- Amount keypad is shared by QRIS and Fund Transfer amount entry.

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

### Build watch app from terminal

```bash
xcodebuild -project OCBC.xcodeproj -scheme "OCBC Watch App" -destination "platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)" build
```

## Roadmap (next)

- Add Fund Transfer post-PIN step (verification/confirmation screen) and end-to-end submit/acknowledgement flow.
- Finalize Fund Transfer validation payload fields for scheduled/recurring transfers (`interval`, `recurStartDate`, `recurEndDate`).
- Expand feature-level tests around Fund Transfer continue/validation and route transitions.
