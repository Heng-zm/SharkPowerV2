//
//  SharkPowerProtocolTests.swift
//  SharkPowerV2Tests
//
//  Unit tests verifying protocol safety, unverified guards, and configuration nil values.
//  RULE 1 & RULE 2 COMPLIANT.
//

import XCTest
import SwiftUI
@testable import SharkPowerV2

final class SharkPowerProtocolTests: XCTestCase {

    func testUnverifiedProtocolThrowsOnEncode() {
        let proto = DefaultSharkPowerProtocol(config: .unverified)
        let command = LightingCommand.setMode(.forward)

        XCTAssertFalse(proto.config.isVerified, "Unverified config must have isVerified = false")
        XCTAssertNil(proto.config.serviceUUID, "Unverified service UUID must be nil")
        XCTAssertNil(proto.config.writeCharacteristicUUID, "Unverified characteristic UUID must be nil")

        XCTAssertThrowsError(try proto.encode(command)) { error in
            guard let protoError = error as? SharkPowerProtocolError else {
                XCTFail("Expected SharkPowerProtocolError but received \(error)")
                return
            }
            XCTAssertEqual(protoError, SharkPowerProtocolError.unverifiedProtocol)
        }
    }

    func testUnverifiedProtocolThrowsOnDecode() {
        let proto = DefaultSharkPowerProtocol(config: .unverified)
        let dummyData = Data([0x01, 0x02, 0x03])

        XCTAssertThrowsError(try proto.decode(dummyData)) { error in
            guard let protoError = error as? SharkPowerProtocolError else {
                XCTFail("Expected SharkPowerProtocolError but received \(error)")
                return
            }
            XCTAssertEqual(protoError, SharkPowerProtocolError.unverifiedProtocol)
        }
    }

    func testProtocolConfigDefaultsAreStrictlyNil() {
        let config = SharkPowerProtocolConfig.unverified
        XCTAssertNil(config.serviceUUID)
        XCTAssertNil(config.writeCharacteristicUUID)
        XCTAssertNil(config.notifyCharacteristicUUID)
        XCTAssertFalse(config.isVerified)
    }
}
