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
        wait(for: [expectationConnect], timeout: 5.0)

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
        wait(for: [expectationApply], timeout: 5.0)
    }

    func testSimulationManagerAppliesAllLightingModesSuccessfully() {
        let sim = SimulationManager()
        sim.isEnabled = true
        sim.shouldSimulateErrors = false

        for mode in LightingMode.allCases {
            let exp = expectation(description: "Simulate apply for \(mode.rawValue)")
            sim.simulateApply(command: .setMode(mode)) { result in
                switch result {
                case .success(let resp):
                    XCTAssertTrue(resp.success)
                    exp.fulfill()
                case .failure(let err):
                    XCTFail("Failed simulation for \(mode): \(err)")
                }
            }
            wait(for: [exp], timeout: 5.0)
        }
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
        wait(for: [expectationApplyError], timeout: 5.0)
    }
}
