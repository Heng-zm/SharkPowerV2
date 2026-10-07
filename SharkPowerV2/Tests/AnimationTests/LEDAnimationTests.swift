//
//  LEDAnimationTests.swift
//  SharkPowerV2Tests
//
//  Unit tests verifying continuous optical animation math, bounds, loops,
//  speed, brightness, LightingMode discovery, factory routing, and preset persistence.
//  Strictly compliant with Section 23 of SUPRE RACERS LED Mode Import Specification.
//

import XCTest
import SwiftUI
@testable import SharkPowerV2

// MARK: - 1. LightingModeTests
final class LightingModeTests: XCTestCase {

    func testAllDiscoveredLightingModesPresent() {
        let expectedModes: [LightingMode] = [.forward, .reverse, .trailing, .chasing, .staticGlow]
        XCTAssertEqual(LightingMode.allCases.count, 5, "Exactly 5 modes must be present per SUPRE RACERS evidence")
        XCTAssertEqual(LightingMode.allCases, expectedModes)
    }

    func testCaseInsensitiveRawValueParsing() {
        XCTAssertEqual(LightingMode(rawValue: "forward"), .forward)
        XCTAssertEqual(LightingMode(rawValue: "FORWARD"), .forward)
        XCTAssertEqual(LightingMode(rawValue: "Forward"), .forward)

        XCTAssertEqual(LightingMode(rawValue: "reverse"), .reverse)
        XCTAssertEqual(LightingMode(rawValue: "REVERSE"), .reverse)

        XCTAssertEqual(LightingMode(rawValue: "trailing"), .trailing)
        XCTAssertEqual(LightingMode(rawValue: "TRAILING"), .trailing)

        XCTAssertEqual(LightingMode(rawValue: "chasing"), .chasing)
        XCTAssertEqual(LightingMode(rawValue: "CHASING"), .chasing)

        XCTAssertEqual(LightingMode(rawValue: "static"), .staticGlow)
        XCTAssertEqual(LightingMode(rawValue: "STATIC"), .staticGlow)
        XCTAssertEqual(LightingMode(rawValue: "staticGlow"), .staticGlow)
        XCTAssertEqual(LightingMode(rawValue: "staticglow"), .staticGlow)
    }

    func testUnknownRawValueReturnsNil() {
        XCTAssertNil(LightingMode(rawValue: "unknown"))
        XCTAssertNil(LightingMode(rawValue: "dotMatrix"))
        XCTAssertNil(LightingMode(rawValue: ""))
    }

    func testModeTelemetryAndStatusMetadata() {
        for mode in LightingMode.allCases {
            XCTAssertFalse(mode.originalName.isEmpty, "Original name must be documented for \(mode)")
            XCTAssertFalse(mode.iconName.isEmpty, "Icon name must be provided for \(mode)")
            XCTAssertFalse(mode.description.isEmpty, "Description must be provided for \(mode)")
            XCTAssertEqual(mode.discoveryStatus, "DISCOVERED")
            XCTAssertEqual(mode.implementationStatus, "IMPLEMENTED")
            XCTAssertEqual(mode.hardwareStatus, "TBD")
        }
    }

    func testLEDModeTypealiasInterchangeability() {
        let mode: LEDMode = .forward
        let lightingMode: LightingMode = mode
        XCTAssertEqual(lightingMode, .forward)
        XCTAssertEqual(LEDMode.allCases, LightingMode.allCases)
    }
}

// MARK: - 2. LEDAnimationFactoryTests
final class LEDAnimationFactoryTests: XCTestCase {

    func testFactoryReturnsConcreteAnimationForEachMode() {
        XCTAssertTrue(LEDAnimationFactory.animation(for: .staticGlow) is StaticAnimation)
        XCTAssertTrue(LEDAnimationFactory.animation(for: .forward) is ForwardAnimation)
        XCTAssertTrue(LEDAnimationFactory.animation(for: .reverse) is ReverseAnimation)
        XCTAssertTrue(LEDAnimationFactory.animation(for: .trailing) is TrailingAnimation)
        XCTAssertTrue(LEDAnimationFactory.animation(for: .chasing) is ChasingAnimation)
    }

    func testFactoryInstanceMethod() {
        let factory = LEDAnimationFactory.shared
        for mode in LightingMode.allCases {
            let anim = factory.createAnimation(for: mode)
            XCTAssertNotNil(anim, "Factory must create non-nil animation for \(mode)")
        }
    }
}

// MARK: - 3. AnimationBoundsTests
final class AnimationBoundsTests: XCTestCase {

    func testAllModesProduceFiniteAndClampedIntensities() {
        let testTimes: [TimeInterval] = [0.0, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0]
        let testPositions = stride(from: 0.0, through: 1.0, by: 0.05).map { CGFloat($0) }
        let params = LEDAnimationParameters(speed: 0.6, brightness: 0.9)

        for mode in LightingMode.allCases {
            let anim = LEDAnimationFactory.animation(for: mode)

            for time in testTimes {
                for pos in testPositions {
                    let intensity = anim.intensity(at: pos, time: time, parameters: params)

                    XCTAssertTrue(intensity.isFinite, "Intensity must be finite for mode \(mode) at pos \(pos), t \(time)")
                    XCTAssertFalse(intensity.isNaN, "Intensity must not be NaN for mode \(mode) at pos \(pos), t \(time)")
                    XCTAssertGreaterThanOrEqual(intensity, 0.0, "Intensity must be >= 0.0 for mode \(mode) at pos \(pos)")
                    XCTAssertLessThanOrEqual(intensity, 1.0, "Intensity must be <= 1.0 for mode \(mode) at pos \(pos)")
                }
            }
        }
    }
}

// MARK: - 4. AnimationLoopTests
final class AnimationLoopTests: XCTestCase {

    func testPeriodicLoopContinuity() {
        let params = LEDAnimationParameters(speed: 0.5, brightness: 1.0)
        let frequency = params.frequency
        let period: TimeInterval = 1.0 / frequency

        // Test periodic repeating for looping animations
        let baseTime: TimeInterval = 0.3
        let nextCycleTime: TimeInterval = baseTime + period

        for mode in LightingMode.allCases {
            let anim = LEDAnimationFactory.animation(for: mode)
            let val1 = anim.intensity(at: 0.5, time: baseTime, parameters: params)
            let val2 = anim.intensity(at: 0.5, time: nextCycleTime, parameters: params)

            XCTAssertEqual(val1, val2, accuracy: 0.02, "Mode \(mode) must repeat periodically at t and t+T")
        }
    }

    func testReverseAnimationMirrorsForwardAnimation() {
        let forward = ForwardAnimation()
        let reverse = ReverseAnimation()
        let params = LEDAnimationParameters(speed: 0.5, brightness: 1.0)

        let time: TimeInterval = 0.5
        let fIntensity = forward.intensity(at: 0.2, time: time, parameters: params)
        let rIntensity = reverse.intensity(at: 0.8, time: time, parameters: params)

        XCTAssertEqual(fIntensity, rIntensity, accuracy: 0.001)
    }
}

// MARK: - 5. AnimationSpeedTests
final class AnimationSpeedTests: XCTestCase {

    func testAnimationDoesNotCrashAtSpeedZero() {
        let params = LEDAnimationParameters(speed: 0.0, brightness: 1.0)
        XCTAssertEqual(params.speed, 0.0)

        for mode in LightingMode.allCases {
            let anim = LEDAnimationFactory.animation(for: mode)
            let intensity = anim.intensity(at: 0.5, time: 1.0, parameters: params)
            XCTAssertTrue(intensity.isFinite)
            XCTAssertGreaterThanOrEqual(intensity, 0.0)
            XCTAssertLessThanOrEqual(intensity, 1.0)
        }
    }

    func testAnimationDoesNotCrashAtSpeedOne() {
        let params = LEDAnimationParameters(speed: 1.0, brightness: 1.0)
        XCTAssertEqual(params.speed, 1.0)

        for mode in LightingMode.allCases {
            let anim = LEDAnimationFactory.animation(for: mode)
            let intensity = anim.intensity(at: 0.5, time: 1.0, parameters: params)
            XCTAssertTrue(intensity.isFinite)
            XCTAssertGreaterThanOrEqual(intensity, 0.0)
            XCTAssertLessThanOrEqual(intensity, 1.0)
        }
    }

    func testFrequencyMonotonicallyIncreasesWithSpeed() {
        let pMin = LEDAnimationParameters(speed: 0.0)
        let pMid = LEDAnimationParameters(speed: 0.5)
        let pMax = LEDAnimationParameters(speed: 1.0)

        XCTAssertLessThan(pMin.frequency, pMid.frequency)
        XCTAssertLessThan(pMid.frequency, pMax.frequency)
    }
}

// MARK: - 6. AnimationBrightnessTests
final class AnimationBrightnessTests: XCTestCase {

    func testBrightnessClampingAndNormalization() {
        let underclamped = LEDAnimationParameters(speed: 0.5, brightness: -0.5)
        XCTAssertEqual(underclamped.brightness, 0.0)

        let overclamped = LEDAnimationParameters(speed: 0.5, brightness: 1.8)
        XCTAssertEqual(overclamped.brightness, 1.0)
    }

    func testBrightnessAtZeroProducesSafeOutput() {
        let params = LEDAnimationParameters(speed: 0.5, brightness: 0.0)
        for mode in LightingMode.allCases {
            let anim = LEDAnimationFactory.animation(for: mode)
            let intensity = anim.intensity(at: 0.5, time: 0.5, parameters: params)
            XCTAssertTrue(intensity.isFinite)
            XCTAssertGreaterThanOrEqual(intensity, 0.0)
            XCTAssertLessThanOrEqual(intensity, 1.0)
        }
    }

    func testBrightnessAtMaxProducesFullIntensity() {
        let params = LEDAnimationParameters(speed: 0.5, brightness: 1.0)
        let staticAnim = StaticAnimation()
        let intensity = staticAnim.intensity(at: 0.5, time: 0.0, parameters: params)
        XCTAssertEqual(intensity, 1.0)
    }
}

// MARK: - 7. PresetModePersistenceTests
final class PresetModePersistenceTests: XCTestCase {

    func testValidPresetModePersistence() {
        for mode in LightingMode.allCases {
            let preset = SavedPreset(
                name: "Test \(mode.rawValue)",
                mode: mode.rawValue,
                colorHex: "#00E5FF",
                brightness: 0.8,
                speed: 0.5
            )

            XCTAssertEqual(preset.modeRawValue, mode.rawValue)
            XCTAssertEqual(preset.lightingMode, mode)
            XCTAssertTrue(preset.isRecognizedMode)
        }
    }

    func testUnknownPresetModeRecoversGracefullyWithoutCrashing() {
        let preset = SavedPreset(
            name: "Corrupted Preset",
            mode: "non_existent_future_mode",
            colorHex: "#FF0000",
            brightness: 0.7,
            speed: 0.3
        )

        XCTAssertFalse(preset.isRecognizedMode, "Unknown mode rawValue must flag isRecognizedMode = false")
        XCTAssertEqual(preset.lightingMode, .forward, "Unknown mode must safely fall back to .forward default")
        XCTAssertEqual(preset.modeRawValue, "non_existent_future_mode", "Original rawValue must be retained for diagnostics")
    }
}
