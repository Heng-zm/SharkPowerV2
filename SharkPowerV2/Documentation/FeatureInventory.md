# Shark Power V2 — Feature Inventory & Hardware Verification Matrix

> **Source of Truth** for Shark Power V2 / SUPRE RACERS Rebuild Project.
> Strict compliance with **Rule 1 ("Do Not Guess")** and **Rule 2 ("Verified ≠ Implemented")**.

---

## 1. Status Definitions

* **ORIGINAL APP DISCOVERED**: Verified presence in original SUPRE RACERS app (`com.sharkpower.supreracers`) from store metadata, UI, and APK package evidence.
* **IOS IMPLEMENTED**: Fully implemented, compiled, and rendered using native SwiftUI `Canvas`, `TimelineView`, and `LEDAnimationFactory`.
* **SIMULATION AVAILABLE**: Operating within `SimulationManager` offline lifecycle workflows without physical BLE hardware.
* **PHYSICAL HARDWARE VERIFIED**: Confirmed via physical testing and packet sniffing on actual **Shark Power V2** controller hardware.

> **CRITICAL ARCHITECTURAL PRINCIPLE:**
> ```text
> Original Discovered ≠ iOS Implemented ≠ Simulation Available ≠ Physical Hardware Verified
> ```
> An iOS feature can be `IMPLEMENTED` and `SIMULATION AVAILABLE` while physical hardware confirmation remains `TBD`.

---

## 2. Hardware Verification Matrix (Section 27 Source of Truth)

| ID | Feature Name | Original App Status | iOS Status | Simulation Status | Physical Hardware Status | Evidence & Architecture Notes |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| **M-01** | **Forward Slide** | **DISCOVERED** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | `ForwardAnimation` via continuous `LEDAnimationFactory` |
| **M-02** | **Reverse Slide** | **DISCOVERED** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | `ReverseAnimation` via continuous `LEDAnimationFactory` |
| **M-03** | **Trailing Fade Flow** | **DISCOVERED** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | `TrailingAnimation` with exponential decay |
| **M-04** | **Chasing Segments** | **DISCOVERED** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | `ChasingAnimation` with synchronized lockstep |
| **M-05** | **Static Solid Glow** | **DISCOVERED** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | `StaticAnimation` solid uniform illumination |
| **F-06** | **Color Customization** | **DISCOVERED** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | RGB picker + automotive palette; BLE write BLOCKED |
| **F-07** | **Speed Control** | **DISCOVERED** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | 0.0...1.0 slider adjusting preview frequency; BLE write BLOCKED |
| **F-08** | **Brightness Control**| **DISCOVERED** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | 0.0...1.0 slider adjusting luminous output; BLE write BLOCKED |
| **F-09** | **Live Sequential Sim**| **N/A (Upgraded)** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | 60 FPS `Canvas` + `TimelineView` continuous optic tube |
| **F-10** | **Decoupled Apply** | **N/A (Upgraded)** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | `DraftLightingState` separated from hardware state |
| **F-11** | **BLE Scanner** | **DISCOVERED** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | `BLEScanner` CoreBluetooth central + RSSI meter |
| **F-12** | **Auto-Reconnect** | **DISCOVERED** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | SwiftData `KnownDevice` paired device persistence |
| **F-13** | **Service UUID** | **TBD** | **TBD** | **AVAILABLE** | **NOT VERIFIED (TBD)** | `SharkPowerProtocolConfig.serviceUUID == nil` pending capture |
| **F-14** | **Characteristic UUID**| **TBD** | **TBD** | **AVAILABLE** | **NOT VERIFIED (TBD)** | `SharkPowerProtocolConfig.writeCharacteristicUUID == nil` pending capture |
| **F-15** | **Packet Format** | **TBD** | **TBD** | **AVAILABLE** | **NOT VERIFIED (TBD)** | Hardware codec throws `unverifiedProtocol`; zero invented bytes |
| **F-16** | **Command Throttling** | **N/A (Upgraded)** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | `BLECommandQueue` actor with deduplication & retry |
| **F-17** | **Saved Presets** | **N/A (Upgraded)** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | SwiftData local offline persistence (`SavedPreset`) |
| **F-18** | **Diagnostics** | **N/A (Upgraded)** | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** | Live telemetry screen (`DiagnosticsView`) & verification status |

See detailed documentation:
* [SUPRE_RACERS_LED_MODES.md](file:///c:/Users/Ozo/Desktop/New%20folder/docs/SUPRE_RACERS_LED_MODES.md)
* [SUPRE_RACERS_MODE_MAPPING.md](file:///c:/Users/Ozo/Desktop/New%20folder/docs/SUPRE_RACERS_MODE_MAPPING.md)

---

## 3. Protocol Safety Guard Implementation

Per Rule 1:
> *"Never invent BLE Service UUIDs, Characteristic UUIDs, BLE commands, Packet structures, Opcode values, CRC/checksum algorithms, timing values, hardware capabilities, device responses, undocumented lighting modes."*

In `SharkPowerProtocol.swift`:
```swift
public final class DefaultSharkPowerProtocol: SharkPowerProtocol {
    public let config: SharkPowerProtocolConfig

    public func encode(_ command: LightingCommand) throws -> Data {
        guard config.isVerified else {
            throw SharkPowerProtocolError.unverifiedProtocol
        }
        ...
    }
}
```

* Real hardware transmission throws `unverifiedProtocol`.
* `SimulationManager` handles offline QA and preview without emitting unverified packets to air.
* Hardware reverse-engineering procedure documented in Section 12 will replace `nil` values only after physical packet evidence is captured.
