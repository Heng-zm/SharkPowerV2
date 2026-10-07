//
//  HomeViewModelTests.swift
//  SharkPowerV2Tests
//
//  Unit tests for Home dashboard state coordination and preset loading.
//

import XCTest
import SwiftUI
@testable import SharkPowerV2

final class HomeViewModelTests: XCTestCase {

    @MainActor
    func testInitialDashboardDefaults() {
        let vm = HomeViewModel()
        XCTAssertEqual(vm.selectedMode, .forward)
        XCTAssertEqual(vm.applyState, .idle)
        XCTAssertGreaterThan(vm.parameters.brightness, 0.5)
    }

    @MainActor
    func testLoadPresetUpdatesViewModelParameters() {
        let vm = HomeViewModel()
        vm.loadPreset(
            mode: .chasing,
            colorHex: "#FF0000",
            brightness: 0.8,
            speed: 0.4
        )

        XCTAssertEqual(vm.selectedMode, .chasing)
        XCTAssertEqual(vm.parameters.brightness, 0.8)
        XCTAssertEqual(vm.parameters.speed, 0.4)
    }
}
