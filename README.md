# Shark Power V2 — Native iOS Lighting Controller

[![Build & Test iOS](https://github.com/sharkpower/shark-power-v2-ios/actions/workflows/build-ios.yml/badge.svg)](https://github.com/sharkpower/shark-power-v2-ios/actions/workflows/build-ios.yml)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0+-black.svg?style=flat&logo=apple)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9%20%7C%206.0-orange.svg?style=flat&logo=swift)](https://swift.org)
[![UI Framework](https://img.shields.io/badge/UI-SwiftUI%20Canvas-blue.svg?style=flat)](https://developer.apple.com/documentation/swiftui/canvas)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern, Apple-grade native iOS controller for the **Shark Power V2** sequential/continuous LED lighting system (originally paired with the *SUPRE RACERS* mobile utility).

Designed from the ground up for automotive lighting enthusiasts with a **dark-cockpit-first aesthetic**, **continuous light-bar simulation**, and **rock-solid CoreBluetooth architecture**.

---

## 1. Visual Philosophy — The Continuous Light Bar

Unlike generic RGB LED controllers that draw cartoonish dot circles (`● ○ ○ ○`), the Shark Power V2 hardware is a **continuous sequential optic light strip**.

```text
Continuous Light Bar Visualization:
████░░░░░░░░ →  (Headlight / Taillight Sequential Beam)
██████░░░░░░ →
████████░░░░ →
████████████ →
```

### Visual Characteristics
* **Zero Dot Clutter**: No circular LED dots or discrete matrix pins.
* **Continuous Optical Core**: Rendered in SwiftUI `Canvas` with an inner hot specular filament (COB / neon-flex look).
* **Multi-Layer Ambient Bloom**: Photorealistic optic dispersion and soft ground reflection on the dark instrument panel.
* **TimelineView (.animation)**: True continuous 60 FPS animation evaluated via physical elapsed time rather than frame counters.

---

## 2. Core UX Flow

```text
┌───────────┐     ┌─────────────┐     ┌──────────────┐     ┌───────────┐     ┌─────────┐
│  CONNECT  │ ──► │ SELECT MODE │ ──► │ LIVE PREVIEW │ ──► │ CUSTOMIZE │ ──► │  APPLY  │
└───────────┘     └─────────────┘     └──────────────┘     └───────────┘     └─────────┘
```

The application strictly decouples the **live preview** from the **hardware device state**. Users can freely experiment with patterns, frequencies, and color palettes without bombarding the physical BLE device with rapid packet bursts. Tapping **APPLY TO DEVICE** dispatches the validated configuration through a serialized, deduplicated command queue.

---

## 3. Supported Continuous Animation Modes

| Mode | Visual Representation | Description |
| :--- | :--- | :--- |
| **Static** | `████████████████` | Uniform continuous illumination across the entire strip length. |
| **Forward** | `████░░░░░░░░░░░░ →` | Smooth sequential light segment sliding continuously left to right. |
| **Reverse** | `← ░░░░░░░░░░░░████` | Smooth sequential light segment sliding continuously right to left. |
| **Trailing** | `███▓▒░░░░░░░░░░░░` | Intense leading front edge with an exponential optical falloff tail. |
| **Chasing** | `██░░░░██░░░░██░░` | Multiple continuous light segments moving through the strip in lockstep. |

---

## 4. Architecture & Clean Separation

```text
SharkPowerV2/
├── App/                # App entrypoint, SwiftData ModelContainer, tab routing
├── Core/
│   ├── Bluetooth/      # BLEScanner, BLEConnection, BLEGATTClient, BLECommandQueue
│   ├── Device/         # SharkPowerDevice facade, SharkPowerProtocol codec, LightingCommand
│   └── Errors/         # Localized user errors & diagnostic telemetry
├── Features/
│   ├── Home/           # Cockpit dashboard, quick pattern pills, sliders, Apply action
│   ├── Preview/        # Canvas continuous renderer, TimelineView, animation math
│   ├── Devices/        # Discovery screen, 10-segment RSSI meter, state machine
│   ├── Presets/        # SwiftData persistent presets with mini continuous previews
│   ├── Settings/       # Theme, engine speed, diagnostics console, GATT inspector
│   └── Sheets/         # Bottom sheets for automotive palette and mode picker
├── Data/               # SwiftData @Model (SavedPreset, KnownDevice)
├── DesignSystem/       # Automotive dark tokens, haptics, glow sliders, action buttons
└── Tests/              # Comprehensive unit tests for animation, BLE, and protocol
```

### Protocol Safety Layer
* **No Invented Protocol Details**: Proprietary UUIDs and frame structures are cleanly isolated in `SharkPowerProtocolConfig` and marked with `isPendingVerification = true`.
* **Hardware Sniffing Ready**: Pluggable codec layer allows hot-swapping byte encodings once physical device logs are captured.
* **Built-in Simulation Mode**: Enables 100% testing on the Xcode iOS Simulator and offline devices without physical BLE hardware present.

---

## 5. Build & CI/CD Instructions

### Requirements
* macOS Sonoma (14.0+) or macOS Sequoia (15.0+)
* Xcode 15.4+ or Xcode 16.0+
* Swift 5.9+ / 6.0
* Apple Developer Account (for signed IPA distribution)

### Local macOS Build Workflow

```bash
# 1. Pre-flight integrity & security check
./scripts/ci-check.sh

# 2. Compile Release build
./scripts/build.sh

# 3. Create .xcarchive
./scripts/archive.sh

# 4. Export & validate .ipa
./scripts/export-ipa.sh
```

Exported IPA will be verified and stored in `build/ipa/SharkPowerV2.ipa`.

---

## 6. GitHub Actions Workflows

### 1. `build-ios.yml` (Pull Requests & Pushes)
Runs on every PR and push to `main`:
* Checks repository integrity
* Runs automated unit test suite on iPhone 15 Simulator
* Builds Release archive to ensure compilation passes without errors

### 2. `release-ios.yml` (Signed Release & Tag Workflow)
Triggered via manual `workflow_dispatch` or on Git tag push (`v*.*.*`):
* Decodes distribution certificate (`APPLE_CERTIFICATE_BASE64`) into a temporary keychain
* Installs provisioning profile (`PROVISIONING_PROFILE_BASE64`)
* Builds signed Release archive
* Exports and validates `SharkPowerV2.ipa`
* Generates GitHub Release and attaches IPA artifact

#### Required GitHub Secrets for Signed IPA Export:
* `APPLE_CERTIFICATE_BASE64`: Base64 encoded `.p12` distribution certificate
* `APPLE_CERTIFICATE_PASSWORD`: Password for the `.p12` certificate
* `PROVISIONING_PROFILE_BASE64`: Base64 encoded `.mobileprovision` file
* `KEYCHAIN_PASSWORD`: (Optional) Temporary keychain password

---

## 7. License

Distributed under the [MIT License](LICENSE).
