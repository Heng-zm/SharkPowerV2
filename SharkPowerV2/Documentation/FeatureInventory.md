# Shark Power V2 — Feature Inventory & Verification Matrix

This document tracks every feature of the Shark Power V2 sequential LED lighting controller, categorized strictly by verification status per project specification:

* **VERIFIED**: Behavior confirmed from the original SUPRE RACERS / Shark Power application and hardware.
* **UNKNOWN (TBD)**: Behavior that cannot yet be confirmed without direct hardware capture or vendor disclosure.
* **IMPLEMENTED**: Behavior successfully implemented and integrated in the new native iOS architecture.

---

## 1. Feature Matrix

| ID | Feature Domain | Feature Name | Status | Original Behavior (SUPRE RACERS) | Rebuilt Architecture Handling |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **F-01** | **Lighting** | Continuous Forward Slide | **VERIFIED** / **IMPLEMENTED** | Light segment moves sequentially left-to-right across strip | Custom `ForwardAnimation` via continuous `Canvas` renderer |
| **F-02** | **Lighting** | Continuous Reverse Slide | **VERIFIED** / **IMPLEMENTED** | Light segment moves right-to-left sequentially | Custom `ReverseAnimation` via continuous `Canvas` renderer |
| **F-03** | **Lighting** | Trailing Fade Flow | **VERIFIED** / **IMPLEMENTED** | High-intensity leading head with an exponential fading tail | Custom `TrailingAnimation` with smooth falloff |
| **F-04** | **Lighting** | Chasing Segments | **VERIFIED** / **IMPLEMENTED** | Multiple sequential continuous light blocks traversing strip | Custom `ChasingAnimation` with normalized period spacing |
| **F-05** | **Lighting** | Static Solid Glow | **VERIFIED** / **IMPLEMENTED** | Constant continuous illumination across full strip length | Custom `StaticAnimation` with solid bloom core |
| **F-06** | **Lighting** | Color Customization | **VERIFIED** / **IMPLEMENTED** | Full RGB palette selection + preset color swatches | Native `ColorPicker` + curated automotive palette swatches |
| **F-07** | **Lighting** | Speed Control | **VERIFIED** / **IMPLEMENTED** | Slider adjusting slide travel frequency (0% to 100%) | Continuous normalized speed parameter `0.0...1.0` |
| **F-08** | **Lighting** | Brightness Control | **VERIFIED** / **IMPLEMENTED** | Dimmer slider (0% to 100%) controlling luminous output | Continuous normalized parameter `0.0...1.0` applied to alpha/glow |
| **F-09** | **UX / Preview** | Live Sequential Simulation | **IMPLEMENTED** | Original app had static/rudimentary preview | Full 60 FPS `TimelineView` + `Canvas` continuous headlight beam |
| **F-10** | **UX / Control** | Decoupled Preview & Apply | **IMPLEMENTED** | Original app wrote continuously over BLE | Separate Preview vs Apply button to avoid accidental hardware flash |
| **F-11** | **Bluetooth** | BLE Scanner & Discovery | **VERIFIED** / **IMPLEMENTED** | Scans for nearby devices advertised by vendor | `BLEScanner` with CoreBluetooth state machine & RSSI meter |
| **F-12** | **Bluetooth** | Auto-Reconnect | **VERIFIED** / **IMPLEMENTED** | Connects to last paired device on launch if available | `KnownDevice` persistent storage via SwiftData + auto-connect |
| **F-13** | **Bluetooth** | Service UUID | **UNKNOWN (TBD)** | Proprietary GATT Service UUID advertised by hardware | Abstracted via `SharkPowerProtocolConfig` (Pending Verification) |
| **F-14** | **Bluetooth** | Characteristic UUID | **UNKNOWN (TBD)** | Proprietary GATT Write/Notify Characteristic UUID | Abstracted via `SharkPowerProtocolConfig` (Pending Verification) |
| **F-15** | **Bluetooth** | Command Packet Byte Structure | **UNKNOWN (TBD)** | Exact byte frame (e.g. Header, Opcode, Length, Payload, CRC) | `SharkPowerProtocol` codec layer with documented TBD frame |
| **F-16** | **Bluetooth** | Command Throttling & Queue | **IMPLEMENTED** | Prone to dropped packets under rapid slider drag in original | `BLECommandQueue` with deduplication, serialization, & timeout |
| **F-17** | **Data** | Saved Presets | **IMPLEMENTED** | Missing or rudimentary in original app | SwiftData `@Model` `SavedPreset` with local offline persistence |
| **F-18** | **Diagnostics** | Connection & GATT Inspector | **IMPLEMENTED** | None in original app | Live diagnostic console & BLE event logging for field verification |

---

## 2. Hardware Protocol Abstraction Strategy

Per the specification:
> "Never invent BLE UUIDs, commands, packets, timing values, or undocumented hardware behavior. If the BLE protocol is unknown, create an abstraction layer and clearly mark the protocol implementation as pending verification."

### Abstracted Interface:
1. `SharkPowerProtocol`: Defines protocol contract (`encode(command:)`, `decode(data:)`).
2. `SharkPowerProtocolConfig`: Contains configurable Service and Characteristic UUIDs, currently marked with clear placeholder identifiers:
   - `serviceUUID`: Configurable (defaults to verification probe UUID)
   - `writeCharacteristicUUID`: Configurable
   - `notifyCharacteristicUUID`: Configurable
3. `BLECommandQueue`: Protects CoreBluetooth buffer overflow by queuing and deduplicating commands before dispatch.
4. `SimulationMode`: Built-in simulator allows testing the complete UI, preview, presets, and state machine on iOS Simulator and iPhones without requiring immediate physical BLE pairing.
