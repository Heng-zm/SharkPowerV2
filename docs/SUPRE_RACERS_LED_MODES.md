# SUPRE RACERS LED Lighting Modes — Evidence & Verification Table

> **Project:** Shark Power V2 Native iOS Rebuild  
> **Original Package:** `com.sharkpower.supreracers` (SUPRE RACERS by Foshan Lingchuang Future Information Technology Co., Ltd. / Shark Power)  
> **Strict Compliance:** Rule 1 ("Do Not Guess") and Rule 2 ("Verified ≠ Implemented")

---

## 1. Verification Classification

To eliminate speculation, all modes are classified under three distinct verification tiers:

* **DISCOVERED**: The mode exists in the original SUPRE RACERS app based on verifiable evidence (UI, APK metadata, App Store listing, user observations).
* **IMPLEMENTED**: The mode has been reproduced in the new native iOS preview and simulation engine (`LEDCanvasRenderer`, `TimelineView`, `LEDAnimationFactory`).
* **PHYSICALLY VERIFIED**: The mode and its underlying BLE transmission have been confirmed on actual physical Shark Power V2 hardware.

```text
Original App Discovered ≠ iOS Preview Implemented ≠ Physically Hardware Verified
```

---

## 2. Mode Evidence Table

| ID | Original Mode Name | Evidence Source | Evidence Details | Optical Behavior Summary | iOS Preview Status | Simulation Status | Physical Hardware Status |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| **M-01** | **Forward** | `UI`, `APK`, `APP_STORE`, `DOCUMENTATION` | Google Play Store & Apple App Store listing for `com.sharkpower.supreracers`; preset mode button "Forward" | Continuous sequential light beam sliding left to right across optic bar; continuous looping motion | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** |
| **M-02** | **Reverse** | `UI`, `APK`, `APP_STORE`, `DOCUMENTATION` | Google Play Store & Apple App Store listing for `com.sharkpower.supreracers`; preset mode button "Reverse" | Continuous sequential light beam sliding right to left across optic bar; continuous looping motion | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** |
| **M-03** | **Trailing** | `UI`, `APK`, `APP_STORE`, `DOCUMENTATION` | Google Play Store & Apple App Store listing for `com.sharkpower.supreracers`; preset mode button "Trailing" | High-intensity leading edge followed by an exponential optical decay tail | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** |
| **M-04** | **Chasing** | `UI`, `APK`, `APP_STORE`, `DOCUMENTATION` | Google Play Store & Apple App Store listing for `com.sharkpower.supreracers`; preset mode button "Chasing" | Multiple continuous light segments traversing the optic strip in lockstep synchronization | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** |
| **M-05** | **Static Glow** | `UI`, `PHYSICAL`, `DOCUMENTATION` | Physical baseline state of continuous optic light tube; steady solid illumination | Uniform continuous luminous intensity across 100% of the light bar | **IMPLEMENTED** | **AVAILABLE** | **NOT VERIFIED (TBD)** |

---

## 3. Detailed Optical Animation Characteristics

### Mode M-01: Forward Slide
* **Direction:** Left → Right (`0.0 → 1.0` normalized axis)
* **Travel Pattern:** Continuous sequential linear translation
* **Number of Moving Regions:** 1 primary beam segment (~32% strip width)
* **Fade Behavior:** Smooth cosine taper at leading and trailing boundaries (`0.06` margin)
* **Leading-Edge Behavior:** Soft luminous ramp
* **Trailing Behavior:** Soft luminous ramp matching leading edge
* **Loop Behavior:** Continuous periodic wrap (`t * frequency mod 1.0`)
* **Speed Response:** Normalized `0.0 ... 1.0` mapped to cycle frequency `0.25 Hz ... 2.4 Hz`
* **Brightness Response:** Global luminous intensity multiplier applied to alpha and bloom
* **Color Response:** Full 24-bit RGB tint with hot specular core (`#FFFFFF`)

### Mode M-02: Reverse Slide
* **Direction:** Right → Left (`1.0 → 0.0` normalized axis)
* **Travel Pattern:** Symmetrical reverse linear translation
* **Number of Moving Regions:** 1 primary beam segment (~32% strip width)
* **Fade Behavior:** Symmetrical cosine taper at boundaries
* **Leading-Edge Behavior:** Soft ramp leading toward left
* **Trailing Behavior:** Soft ramp trailing toward right
* **Loop Behavior:** Continuous periodic wrap in reverse direction
* **Speed Response:** Normalized `0.0 ... 1.0` (0.25 Hz ... 2.4 Hz)
* **Brightness Response:** Proportional intensity scaling
* **Color Response:** Full 24-bit RGB tint

### Mode M-03: Trailing Fade Flow
* **Direction:** Left → Right (`0.0 → 1.0` normalized axis)
* **Travel Pattern:** High-energy beam sweeping across strip with prolonged comet trail
* **Number of Moving Regions:** 1 leading head with extended tail (~65% total span)
* **Fade Behavior:** Exponential optical decay ($e^{-4.5 \times \Delta x}$) behind head
* **Leading-Edge Behavior:** Sharp, high-intensity front cutoff with steep attack
* **Trailing Behavior:** Long, luminous phosphorescent optical dispersion falloff
* **Loop Behavior:** Seamless continuous periodic re-entry
* **Speed Response:** Normalized `0.0 ... 1.0` mapped to sweep rate
* **Brightness Response:** Scaled across head and falloff tail
* **Color Response:** Full 24-bit RGB tint

### Mode M-04: Chasing Segments
* **Direction:** Left → Right (`0.0 → 1.0` normalized axis)
* **Travel Pattern:** Synchronized multi-block continuous wave
* **Number of Moving Regions:** 2 distinct continuous blocks in lockstep ($0.5$ phase offset)
* **Fade Behavior:** Smooth localized cosine taper per block (~22% segment width)
* **Leading-Edge Behavior:** Dual synchronized attack fronts
* **Trailing Behavior:** Dual synchronized decay tails
* **Loop Behavior:** Continuous harmonic phase translation
* **Speed Response:** Normalized `0.0 ... 1.0` mapped to rotation frequency
* **Brightness Response:** Dual-segment amplitude scaling
* **Color Response:** Full 24-bit RGB tint

### Mode M-05: Static Solid Glow
* **Direction:** None (Stationary)
* **Travel Pattern:** Static continuous solid illumination
* **Number of Moving Regions:** 0 (Uniform across entire 100% strip span)
* **Fade Behavior:** None (Constant baseline)
* **Leading-Edge Behavior:** N/A
* **Trailing Behavior:** N/A
* **Loop Behavior:** Static steady-state
* **Speed Response:** Inactive (Speed slider does not affect static mode)
* **Brightness Response:** Uniform global luminous dimming (0% to 100%)
* **Color Response:** Full 24-bit RGB tint with solid specular filament

---

## 4. Hardware BLE Protocol Safety Status

| Parameter | Current Status | Enforcement Guard |
| :--- | :---: | :--- |
| **Service UUID** | **TBD** | Set to `nil` in `SharkPowerProtocolConfig`. Hardware scanning uses non-filtering scan. |
| **Characteristic UUID** | **TBD** | Set to `nil` in `SharkPowerProtocolConfig`. |
| **Packet Opcode Mapping** | **TBD** | Speculative bytes (`0x01, 0x02, etc.`) are **STRICTLY BLOCKED**. |
| **Checksum / CRC Algorithm** | **TBD** | Real hardware codec throws `SharkPowerProtocolError.unverifiedProtocol`. |
| **Apply Transmission** | **BLOCKED** | User tap on APPLY triggers queue serialization; real hardware write throws error to protect hardware. |
| **Simulation Transmission** | **SIMULATED** | Offline `SimulationManager` provides 100% UI and workflow feedback without RF emission. |
