//
//  GoalAlert.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation
import SwiftData

@Model
public final class GoalAlert {
    public var id: UUID = UUID()
    public var scheduledDate: Date = Date()
    public var message: String?
    public var isTriggered: Bool = false
    public var notificationIdentifier: String?
    public var goal: Goal?

    public init(scheduledDate: Date, message: String? = nil) {
        self.id = UUID()
        self.scheduledDate = scheduledDate
        self.message = message
        self.isTriggered = false
        self.notificationIdentifier = nil
    }
    
    // CloudKit-compatible initializer
    public init() {
        self.id = UUID()
        self.scheduledDate = Date()
        self.isTriggered = false
    }

    @Transient
    public var isPast: Bool {
        scheduledDate < Date()
    }

    @Transient
    public var isUpcoming: Bool {
        !isPast && !isTriggered
    }
}
