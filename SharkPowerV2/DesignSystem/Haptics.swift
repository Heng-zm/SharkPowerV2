//
//  Haptics.swift
//  SharkPowerV2
//
//  Automotive haptic feedback manager adhering to iOS best practices.
//

import UIKit

public final class Haptics {
    public static let shared = Haptics()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()

    private init() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }

    public func selectionChanged() {
        selection.selectionChanged()
    }

    public func lightImpact() {
        impactLight.impactOccurred()
    }

    public func mediumImpact() {
        impactMedium.impactOccurred()
    }

    public func heavyImpact() {
        impactHeavy.impactOccurred()
    }

    public func notifySuccess() {
        notification.notificationOccurred(.success)
    }

    public func notifyWarning() {
        notification.notificationOccurred(.warning)
    }

    public func notifyError() {
        notification.notificationOccurred(.error)
    }
}
