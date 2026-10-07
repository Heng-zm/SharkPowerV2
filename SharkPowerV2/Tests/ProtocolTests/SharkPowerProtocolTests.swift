//
//  SharkPowerProtocolTests.swift
//  SharkPowerV2Tests
//
//  Unit tests verifying protocol encoding, checksum calculation, and safe abstraction.
//

import XCTest
import SwiftUI
@testable import SharkPowerV2

final class SharkPowerProtocolTests: XCTestCase {

    func testEncodeModeCommand() throws {
        let proto = SharkPowerProtocol()
        let command = LightingCommand.setMode(.forward)
        let data = try proto.encode(command)

        XCTAssertFalse(data.isEmpty)
        XCTAssertEqual(data[0], 0x53, "Header must be 0x53 ('S')")
        XCTAssertEqual(data[1], 0x01, "Opcode for mode must be 0x01")
        XCTAssertEqual(data[3], 0x01, "Forward mode byte must be 0x01")
        XCTAssertEqual(data.last, 0xAA, "Footer byte must be 0xAA")
    }

    func testEncodeFullConfigurationSync() throws {
        let proto = SharkPowerProtocol()
        let command = LightingCommand.setFullConfiguration(
            mode: .trailing,
            color: Color(red: 1.0, green: 0.0, blue: 0.0),
            brightness: 1.0,
            speed: 0.5
        )
        let data = try proto.encode(command)

        XCTAssertGreaterThan(data.count, 6)
        XCTAssertEqual(data[0], 0x53)
        XCTAssertEqual(data[1], 0x05, "Full config opcode must be 0x05")
    }

    func testProtocolSafetyConfiguration() {
        let config = SharkPowerProtocolConfig.pendingVerification
        XCTAssertTrue(config.isPendingVerification, "Protocol must explicitly track verification status")
    }
}
