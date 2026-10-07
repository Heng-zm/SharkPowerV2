# Shark Power V2 — Feature Inventory & Hardware Verification Matrix

> **Source of Truth** for Shark Power V2 / SUPRE RACERS Rebuild Project.
> Strict compliance with **Rule 1 ("Do Not Guess")** and **Rule 2 ("Verified ≠ Implemented")**.

---

## 1. Status Definitions

* **VERIFIED**: Behavior confirmed through physical testing and packet analysis on the actual **Shark Power V2** hardware.
* **IMPLEMENTED**: Fully implemented, compiled, and validated in the new native iOS architecture.
* **TBD**: Not confirmed yet against physical hardware. Never assumed or invented.
* **SIMULATED**: Functional inside the iOS Simulation Mode without physical hardware connection.

> **CRITICAL ARCHITECTURAL PRINCIPLE:**
> ```text
> Simulation Mode ≠ Hardware Verification
> Implemented ≠ Verified
> ```
> An iOS feature can be `IMPLEMENTED` and `SIMULATED` while the underlying physical hardware behavior remains `TBD`.

---

## 2. Hardware Verification Matrix (Section 27 Source of Truth)

| ID | Feature Name | Hardware Status | iOS Status | Simulation Status | Notes & Evidence |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **F-01** | **Forward Slide** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | Smooth continuous sliding beam left-to-right via `ForwardAnimation` |
| **F-02** | **Reverse Slide** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | Smooth continuous sliding beam right-to-left via `ReverseAnimation` |
| **F-03** | **Trailing Fade Flow** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | Bright leading edge with exponential falloff via `TrailingAnimation` |
| **F-04** | **Chasing Segments** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | Multiple continuous light segments in lockstep via `ChasingAnimation` |
| **F-05** | **Static Solid Glow** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | Solid full-strip continuous illumination via `StaticAnimation` |
| **F-06** | **Color Customization** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | Full RGB picker + curated automotive swatches; BLE RGB dispatch blocked |
| **F-07** | **Speed Control** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | Continuous slider (0.0...1.0) controlling preview frequency; BLE write blocked |
| **F-08** | **Brightness Control**| **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | Continuous slider (0.0...1.0) controlling luminous alpha; BLE write blocked |
| **F-09** | **Live Sequential Sim**| **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | 60 FPS `Canvas` + `TimelineView(.animation)` continuous optic tube |
| **F-10** | **Decoupled Apply** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | `DraftLightingState` separated from hardware state; Apply button barrier |
| **F-11** | **BLE Scanner** | **TBD** | **IMPLEMENTED** | **SIMULATED** | `BLEScanner` CoreBluetooth central manager + simulated discovery |
| **F-12** | **Auto-Reconnect** | **TBD** | **IMPLEMENTED** | **SIMULATED** | App feature via SwiftData `KnownDevice`; hardware auto-pairing TBD |
| **F-13** | **Service UUID** | **TBD** | **TBD** | **SIMULATED** | `SharkPowerProtocolConfig.serviceUUID == nil` until physical sniffing |
| **F-14** | **Characteristic UUID**| **TBD** | **TBD** | **SIMULATED** | `SharkPowerProtocolConfig.writeCharacteristicUUID == nil` until sniffing |
| **F-15** | **Packet Format** | **TBD** | **TBD** | **SIMULATED** | Real hardware codec throws `unverifiedProtocol`; zero invented bytes |
| **F-16** | **Command Throttling** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | `BLECommandQueue` actor with deduplication, serialization, & timeout |
| **F-17** | **Saved Presets** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | SwiftData local offline persistence (`SavedPreset`) |
| **F-18** | **Diagnostics** | **TBD** | **IMPLEMENTED** | **IMPLEMENTED** | Live telemetry screen (`DiagnosticsView`) with GATT & protocol inspector |

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
