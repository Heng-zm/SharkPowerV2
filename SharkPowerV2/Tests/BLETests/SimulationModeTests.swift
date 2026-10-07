//
//  SimulationModeTests.swift
//  SharkPowerV2Tests
//
//  Unit tests validating complete simulation mode workflows without physical hardware.
//

import XCTest
import SwiftUI
@testable import SharkPowerV2

final class SimulationModeTests: XCTestCase {

    func testFakeBLEDeviceConversionAndFluctuation() {
        let fake = FakeBLEDevice(name: "Shark Power V2 (Simulated)", rssi: -60)
        let deviceModel = fake.toBLEDevice()

        XCTAssertEqual(deviceModel.name, "Shark Power V2 (Simulated)")
        XCTAssertEqual(deviceModel.rssi, -60)

        fake.simulateRSSIFluctuation()
        XCTAssertGreaterThanOrEqual(fake.rssi, -95)
        XCTAssertLessThanOrEqual(fake.rssi, -45)
    }

    func testSimulationManagerConnectAndApplyWorkflow() {
        let sim = SimulationManager()
        sim.isEnabled = true
        sim.shouldSimulateErrors = false

        let expectationConnect = expectation(description: "Simulated connect")
        sim.connect { state in
            if case .connected = state {
                expectationConnect.fulfill()
            }
        }
        wait(for: [expectationConnect], timeout: 2.0)

        let expectationApply = expectation(description: "Simulated apply")
        let cmd = LightingCommand.setMode(.trailing)
        sim.simulateApply(command: cmd) { result in
            switch result {
            case .success(let resp):
                XCTAssertTrue(resp.success)
                expectationApply.fulfill()
            case .failure(let err):
                XCTFail("Unexpected simulation failure: \(err)")
            }
        }
        wait(for: [expectationApply], timeout: 2.0)
    }

    func testSimulationManagerErrorInjection() {
        let sim = SimulationManager()
        sim.isEnabled = true
        sim.shouldSimulateErrors = true

        let expectationApplyError = expectation(description: "Simulated apply error injection")
        let cmd = LightingCommand.setMode(.forward)
        sim.simulateApply(command: cmd) { result in
            switch result {
            case .success:
                XCTFail("Expected simulated failure when shouldSimulateErrors is true")
            case .failure:
                expectationApplyError.fulfill()
            }
        }
        wait(for: [expectationApplyError], timeout: 2.0)
    }
}
