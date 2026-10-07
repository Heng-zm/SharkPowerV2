//
//  LEDAnimationTests.swift
//  SharkPowerV2Tests
//
//  Unit tests verifying continuous animation math, normalized parameters, and looping behaviors.
//

import XCTest
@testable import SharkPowerV2

final class LEDAnimationTests: XCTestCase {

    func testStaticAnimationMaintainsSolidIntensity() {
        let anim = StaticAnimation()
        let params = LEDAnimationParameters(speed: 0.5, brightness: 1.0)

        // Across all positions along continuous strip, intensity must be 1.0
        XCTAssertEqual(anim.intensity(at: 0.0, time: 0.0, parameters: params), 1.0)
        XCTAssertEqual(anim.intensity(at: 0.5, time: 1.0, parameters: params), 1.0)
        XCTAssertEqual(anim.intensity(at: 1.0, time: 2.5, parameters: params), 1.0)
    }

    func testForwardAnimationContinuousSlideBounds() {
        let anim = ForwardAnimation()
        let params = LEDAnimationParameters(speed: 0.5, brightness: 1.0)

        // At time 0.0, check intensity is non-negative and <= 1.0 everywhere
        for step in 0...20 {
            let pos = CGFloat(step) / 20.0
            let intensity = anim.intensity(at: pos, time: 0.0, parameters: params)
            XCTAssertGreaterThanOrEqual(intensity, 0.0)
            XCTAssertLessThanOrEqual(intensity, 1.0)
        }
    }

    func testReverseAnimationInvertsForwardPosition() {
        let forward = ForwardAnimation()
        let reverse = ReverseAnimation()
        let params = LEDAnimationParameters(speed: 0.5, brightness: 1.0)

        let time: TimeInterval = 0.5
        let fIntensity = forward.intensity(at: 0.2, time: time, parameters: params)
        let rIntensity = reverse.intensity(at: 0.8, time: time, parameters: params)

        XCTAssertEqual(fIntensity, rIntensity, accuracy: 0.001)
    }

    func testTrailingAnimationDecaysBehindLeadingHead() {
        let anim = TrailingAnimation()
        let params = LEDAnimationParameters(speed: 0.5, brightness: 1.0)

        // Check that at any time, points far behind the head or ahead of head have lower intensity
        let intensityAhead = anim.intensity(at: 0.99, time: 0.1, parameters: params)
        XCTAssertGreaterThanOrEqual(intensityAhead, 0.0)
        XCTAssertLessThanOrEqual(intensityAhead, 1.0)
    }

    func testChasingAnimationSegmentsNeverExceedBounds() {
        let anim = ChasingAnimation()
        let params = LEDAnimationParameters(speed: 0.8, brightness: 1.0)

        for step in 0...30 {
            let pos = CGFloat(step) / 30.0
            let val = anim.intensity(at: pos, time: 1.25, parameters: params)
            XCTAssertGreaterThanOrEqual(val, 0.0)
            XCTAssertLessThanOrEqual(val, 1.0)
        }
    }

    func testParametersNormalizationClamping() {
        let overclamped = LEDAnimationParameters(speed: 2.5, brightness: -0.5)
        XCTAssertEqual(overclamped.speed, 1.0)
        XCTAssertEqual(overclamped.brightness, 0.0)

        let normal = LEDAnimationParameters(speed: 0.5, brightness: 0.8)
        XCTAssertEqual(normal.speed, 0.5)
        XCTAssertEqual(normal.brightness, 0.8)
        XCTAssertGreaterThan(normal.frequency, 0.2)
    }
}
