# Shark Power V2 — Native iOS Lighting Controller

[![Build & Test iOS](https://github.com/sharkpower/shark-power-v2-ios/actions/workflows/build-ios.yml/badge.svg)](https://github.com/sharkpower/shark-power-v2-ios/actions/workflows/build-ios.yml)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0+-black.svg?style=flat&logo=apple)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9%20%7C%206.0-orange.svg?style=flat&logo=swift)](https://swift.org)
[![UI Framework](https://img.shields.io/badge/UI-SwiftUI%20Canvas-blue.svg?style=flat)](https://developer.apple.com/documentation/swiftui/canvas)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern native iOS controller for the **Shark Power V2** sequential/continuous LED lighting system (originally paired with the *SUPRE RACERS* mobile utility).

Built natively in **SwiftUI**, **CoreBluetooth**, **SwiftData**, and **Canvas** with a **dark-cockpit-first aesthetic**, **continuous light-bar simulation**, and **strict hardware protocol safety**.

---

## 1. Core Engineering Principles

### Rule 1 — Do Not Guess
We never invent BLE Service UUIDs, Characteristic UUIDs, command opcodes, packet formats, or checksum algorithms. If a hardware field has not been confirmed on physical Shark Power V2 hardware, it is strictly marked:
```text
TBD
```

### Rule 2 — Verified ≠ Implemented
```text
Simulation Mode ≠ Hardware Verification
Implemented ≠ Verified
```
A feature can be `IMPLEMENTED` in iOS and functional in `SIMULATION` while physical hardware confirmation remains `TBD`.

---

## 2. Hardware Verification Matrix (Source of Truth)

| Feature | Hardware Status | iOS Status | Simulation Status |
| :--- | :---: | :---: | :---: |
| **Forward Slide** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** |
| **Reverse Slide** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** |
| **Trailing** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** |
| **Chasing** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** |
| **Static** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** |
| **RGB Color** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** |
| **Speed Control** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** |
| **Brightness Control** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** |
| **BLE Scanner** | **TBD** | **IMPLEMENTED** | **SIMULATED** |
| **Service UUID** | **TBD** | **TBD** | **SIMULATED** |
| **Characteristic UUID** | **TBD** | **TBD** | **SIMULATED** |
| **Packet Format** | **TBD** | **TBD** | **SIMULATED** |

---

## 3. Visual Philosophy — The Continuous Light Bar

Unlike generic RGB apps that draw discrete LED dots (`● ○ ○ ○`), the Shark Power V2 physical product is a **continuous sequential optic light strip**.

```text
Continuous Light Bar Visualization:
████░░░░░░░░ →  (Headlight / Taillight Sequential Beam)
██████░░░░░░ →
████████░░░░ →
████████████ →
```

### Layered Optical Canvas Rendering
Rendered in SwiftUI `Canvas` via `GraphicsContext`:
1. **Recessed Housing**: Dark carbon acrylic channel with metallic highlight and shadow.
2. **Floor Reflection**: Luminous ambient under-glow projected beneath the bar.
3. **Diffuse Bloom**: Soft photon dispersion proportional to local beam intensity.
4. **Continuous Optic Tube**: Solid continuous light core without dot breaks.
5. **Hot Specular Filament**: 3.5pt central white-hot beam reproducing authentic COB / neon-flex light tubes.
6. **TimelineView (.animation)**: True continuous 60 FPS animation evaluated via physical elapsed time.

---

## 4. User Flow & Decoupled State

```text
CONNECT ──► SELECT MODE ──► LIVE PREVIEW ──► CUSTOMIZE ──► APPLY
```

```text
DraftLightingState ──► Live Preview ──► Apply ──► BLE Command Queue ──► Device
```

Changes to sliders or palettes update `DraftLightingState` and render at 60 FPS immediately. Hardware writes occur only when **APPLY** is tapped.

---

## 5. Simulation Mode

Simulation Mode enables complete UI and workflow development without physical hardware:
* Emulates peripheral discovery and signal RSSI fluctuations.
* Emulates connection lifecycles and realistic Apply acknowledgements.
* Injects simulated hardware errors to validate error UX.
* Clearly labeled with `SIMULATION MODE` to prevent mistaking simulation for hardware verification.

---

## 6. Project Architecture

```text
SharkPowerV2/
├── App/
│   ├── SharkPowerApp.swift             # App entrypoint + SwiftData ModelContainer
│   └── AppRouter.swift                 # Tab navigation (Cockpit, Devices, Presets, Settings)
├── Core/
│   ├── Bluetooth/
│   │   ├── ConnectionState.swift       # 7-stage connection state machine
│   │   ├── BLEProtocols.swift          # Abstract protocol interfaces
│   │   ├── BLEDevice.swift             # Peripheral model with 10-segment RSSI normalization
│   │   ├── BLEScanner.swift            # CoreBluetooth scanner
│   │   ├── BLEConnection.swift         # Peripheral lifecycle & reconnection manager
│   │   ├── BLEGATTClient.swift         # Service & characteristic discovery
│   │   └── BLECommandQueue.swift       # Serialized, deduplicated, retrying queue actor
│   ├── Device/
│   │   ├── LightingCommand.swift       # Decoupled lighting intent models
│   │   ├── SharkPowerProtocol.swift    # Safe protocol codec (guards unverified packets)
│   │   ├── SharkPowerProtocolConfig.swift # nil UUIDs pending hardware capture
│   │   └── SharkPowerDevice.swift      # Unified facade controller
│   ├── Simulation/
│   │   ├── FakeBLEDevice.swift         # Simulated peripheral model
│   │   └── SimulationManager.swift     # Complete offline simulation coordinator
│   └── Errors/
│       └── AppError.swift              # Human-friendly automotive errors & recovery guidance
├── Features/
│   ├── Home/
│   │   ├── DraftLightingState.swift    # Decoupled draft configuration
│   │   ├── HomeView.swift              # Cockpit dashboard with live preview & Apply flow
│   │   └── HomeViewModel.swift         # Dashboard state coordinator
│   ├── Preview/
│   │   ├── LEDAnimation.swift          # LEDAnimation protocol & parameter definitions
│   │   ├── StaticAnimation.swift       # Constant continuous illumination
│   │   ├── ForwardAnimation.swift      # Left-to-right continuous sliding beam
│   │   ├── ReverseAnimation.swift      # Right-to-left continuous sliding beam
│   │   ├── TrailingAnimation.swift     # Leading edge with exponential falloff tail
│   │   ├── ChasingAnimation.swift      # Multiple continuous light segments in lockstep
│   │   ├── LEDCanvasRenderer.swift     # GraphicsContext continuous light tube renderer
│   │   ├── LEDPreviewView.swift        # TimelineView 60fps host with directional indicators
│   │   └── FullScreenPreviewView.swift # Immersive full-screen cockpit experience
│   ├── Devices/
│   │   ├── DevicesView.swift           # Discovered peripherals, 10-segment signal meters
│   │   └── DevicesViewModel.swift      # Discovery & connection controller
│   ├── Presets/
│   │   ├── PresetsView.swift           # Saved presets with live mini continuous previews
│   │   └── PresetsViewModel.swift      # Apply, edit, rename, and delete preset logic
│   ├── Settings/
│   │   ├── SettingsView.swift          # Appearance, haptics, diagnostic console link
│   │   └── SettingsViewModel.swift     # Preferences & log aggregator
│   ├── Diagnostics/
│   │   ├── DiagnosticsView.swift       # In-depth field diagnostics, GATT & protocol inspector
│   │   └── DiagnosticsViewModel.swift  # Telemetry aggregator
│   └── Sheets/
│       ├── ColorPickerSheet.swift      # Curated automotive palette & native ColorPicker
│       └── ModeSelectionSheet.swift    # Mode cards with live mini continuous previews
├── Data/
│   ├── Models/
│   │   ├── SavedPreset.swift           # SwiftData model for saved configurations
│   │   ├── KnownDevice.swift           # SwiftData model for paired devices
│   │   └── AppSettings.swift           # SwiftData model for preferences
│   └── Persistence/
│       └── ModelContainer.swift        # Container factory with seeded default presets
├── DesignSystem/
│   ├── Colors.swift                    # Dark cockpit palette (#0A0D12, neon cyan, daytona red, etc.)
│   ├── Typography.swift                # Automotive Dynamic Type hierarchy
│   ├── Spacing.swift                   # 8pt grid & radius tokens
│   ├── Haptics.swift                   # Tactile feedback generator wrapper
│   └── Components/                     # AutomotiveCard, StatusBadge, GlowSlider, ActionButton
└── Tests/
    ├── AnimationTests/                 # Looping, bounds, and intensity unit tests
    ├── BLETests/                       # Queue deduplication, timeouts, and simulation tests
    ├── ProtocolTests/                  # Safety unverified guards and nil UUID tests
    └── ViewModelTests/                 # Dashboard state and preset loading tests
```

---

## 7. Local Build & CI/CD Workflow

### Local Commands (macOS)
```bash
# 1. Pre-flight sanity and secret scan
./scripts/ci-check.sh

# 2. Compile Release build
./scripts/build.sh

# 3. Create .xcarchive
./scripts/archive.sh

# 4. Export & validate .ipa
./scripts/export-ipa.sh
```

### GitHub Actions
* **`build-ios.yml`**: Runs on PRs and pushes to `main` (integrity check, automated unit tests, Release archive).
* **`release-ios.yml`**: Triggered via `workflow_dispatch` or tags (`v*.*.*`), injects signing credentials, exports signed IPA, and publishes to GitHub Releases.

---

## 8. License

Distributed under the [MIT License](LICENSE).
