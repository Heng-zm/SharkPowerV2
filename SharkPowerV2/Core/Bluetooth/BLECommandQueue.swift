//
//  BLECommandQueue.swift
//  SharkPowerV2
//
//  Serialized, throttled, deduplicating command queue with retries and timeout protection.
//

import Foundation
import CoreBluetooth

public struct QueuedCommand: Identifiable, Equatable {
    public let id: UUID = UUID()
    public let data: Data
    public let characteristicUUID: CBUUID
    public let requiresResponse: Bool
    public let maxRetries: Int
    public var attempts: Int = 0
    public let deduplicationKey: String

    public static func == (lhs: QueuedCommand, rhs: QueuedCommand) -> Bool {
        lhs.deduplicationKey == rhs.deduplicationKey
    }
}

public actor BLECommandQueue {
    private var pendingQueue: [QueuedCommand] = []
    private var isProcessing: Bool = false
    private let defaultTimeout: TimeInterval = 2.0
    private weak var gattClient: BLEGATTClientProtocol?

    public init(gattClient: BLEGATTClientProtocol?) {
        self.gattClient = gattClient
    }

    public func setGATTClient(_ client: BLEGATTClientProtocol?) {
        self.gattClient = client
    }

    /// Enqueues a command with deduplication. If a command with the same key is already queued,
    /// it replaces the pending command rather than piling up stale packets.
    public func enqueue(
        data: Data,
        characteristicUUID: CBUUID,
        deduplicationKey: String,
        requiresResponse: Bool = false,
        maxRetries: Int = 2
    ) async {
        let command = QueuedCommand(
            data: data,
            characteristicUUID: characteristicUUID,
            requiresResponse: requiresResponse,
            maxRetries: maxRetries,
            deduplicationKey: deduplicationKey
        )

        // Deduplication: remove pending stale command with same key
        pendingQueue.removeAll(where: { $0.deduplicationKey == deduplicationKey })
        pendingQueue.append(command)

        if !isProcessing {
            await processNext()
        }
    }

    public func clear() {
        pendingQueue.removeAll()
        isProcessing = false
    }

    private func processNext() async {
        guard !pendingQueue.isEmpty else {
            isProcessing = false
            return
        }

        isProcessing = true
        var currentCommand = pendingQueue.removeFirst()
        currentCommand.attempts += 1

        do {
            try await executeWithTimeout(command: currentCommand, timeout: defaultTimeout)
            // Successfully executed, proceed to next
            await processNext()
        } catch {
            if currentCommand.attempts <= currentCommand.maxRetries {
                // Retry with backoff
                try? await Task.sleep(nanoseconds: 300_000_000)
                pendingQueue.insert(currentCommand, at: 0)
            }
            await processNext()
        }
    }

    private func executeWithTimeout(command: QueuedCommand, timeout: TimeInterval) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                guard let client = self.gattClient else { return }
                try await client.write(
                    data: command.data,
                    characteristicUUID: command.characteristicUUID,
                    responseNeeded: command.requiresResponse
                )
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw NSError(domain: "SharkPower.Queue", code: 408, userInfo: [NSLocalizedDescriptionKey: "Command dispatch timed out"])
            }

            try await group.next()
            group.cancelAll()
        }
    }
}
