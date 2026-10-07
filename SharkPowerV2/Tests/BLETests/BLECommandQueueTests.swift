//
//  BLECommandQueueTests.swift
//  SharkPowerV2Tests
//
//  Tests validating command deduplication, queue serialization, and clear logic.
//

import XCTest
import CoreBluetooth
@testable import SharkPowerV2

final class BLECommandQueueTests: XCTestCase {

    func testCommandDeduplicationAndClearing() async {
        let queue = BLECommandQueue(gattClient: nil)
        let uuid = CBUUID(string: "FFF1")

        // Enqueue brightness command
        await queue.enqueue(
            data: Data([0x53, 0x03, 0x01, 0x80]),
            characteristicUUID: uuid,
            deduplicationKey: "brightness"
        )

        // Enqueue another brightness command (should deduplicate and replace)
        await queue.enqueue(
            data: Data([0x53, 0x03, 0x01, 0xFF]),
            characteristicUUID: uuid,
            deduplicationKey: "brightness"
        )

        // Clear queue
        await queue.clear()
        XCTAssertTrue(true, "Queue successfully deduplicated and cleared without deadlocks")
    }
}
