# SUPRE RACERS Mode Mapping — Migration Source of Truth

> **Migration Specification:** Original SUPRE RACERS (`com.sharkpower.supreracers`) to Shark Power V2 Native iOS Rebuild  
> **Compliance:** Strict compliance with Rule 1 ("Do Not Guess") and Rule 2 ("Verified ≠ Implemented").

---

## 1. Mode Mapping Matrix

| Original SUPRE RACERS Name | Shark Power V2 iOS Identifier | iOS Preview Status | iOS Simulation Status | Physical Hardware Status | Evidence Origin |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Forward** | `LightingMode.forward` (`"Forward"`) | ✅ IMPLEMENTED | ✅ AVAILABLE | ⏳ TBD (NOT VERIFIED) | App Store & Google Play metadata, UI buttons |
| **Reverse** | `LightingMode.reverse` (`"Reverse"`) | ✅ IMPLEMENTED | ✅ AVAILABLE | ⏳ TBD (NOT VERIFIED) | App Store & Google Play metadata, UI buttons |
| **Trailing** | `LightingMode.trailing` (`"Trailing"`) | ✅ IMPLEMENTED | ✅ AVAILABLE | ⏳ TBD (NOT VERIFIED) | App Store & Google Play metadata, UI buttons |
| **Chasing** | `LightingMode.chasing` (`"Chasing"`) | ✅ IMPLEMENTED | ✅ AVAILABLE | ⏳ TBD (NOT VERIFIED) | App Store & Google Play metadata, UI buttons |
| **Static Glow** | `LightingMode.staticGlow` (`"Static"`) | ✅ IMPLEMENTED | ✅ AVAILABLE | ⏳ TBD (NOT VERIFIED) | Physical continuous optical strip baseline |

---

## 2. Control Parameter Mapping

| Original Feature | Shark Power V2 iOS Implementation | Preview Behavior | Simulation Behavior | Hardware BLE Protocol Behavior |
| :--- | :--- | :--- | :--- | :--- |
| **Mode Switching** | `LightingMode` enum & `LEDAnimationFactory` | Instant 60 FPS continuous animation transition via `TimelineView` | Supported via `SimulationManager.simulateApply` | **BLOCKED** (`unverifiedProtocol` guard) |
| **Color Control** | `ColorPickerSheet` (RGB spectrum + automotive swatches) | Sub-pixel GPU `LinearGradient` recoloring with specular core | Supported in local state and simulation ACK | **BLOCKED** (`unverifiedProtocol` guard) |
| **Speed Adjustment** | Continuous `GlowSlider` (`0.0 ... 1.0`) | Dynamic frequency scaling (`0.25 Hz ... 2.4 Hz`) | Supported in local state | **BLOCKED** (`unverifiedProtocol` guard) |
| **Brightness Dimming** | Continuous `GlowSlider` (`0.0 ... 1.0`) | Dynamic luminous alpha & bloom radius scaling | Supported in local state | **BLOCKED** (`unverifiedProtocol` guard) |
| **Power Toggle** | Connection & cockpit state toggle | Turns light tube off/on visually | Simulated ACK | **BLOCKED** (`unverifiedProtocol` guard) |

---

## 3. Status Definitions

* **DISCOVERED**: The mode exists in the original SUPRE RACERS application supported by verifiable evidence.
* **IMPLEMENTED**: The mode is completely built, compiled, and rendering with continuous optical physics in native iOS SwiftUI.
* **SIMULATION AVAILABLE**: The mode executes smoothly within `SimulationManager` offline workflows with full state transitions.
* **PHYSICAL HARDWARE VERIFIED**: The BLE packets and physical lighting response have been verified on an actual Shark Power V2 controller.
