//
//  Subtask.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation
import SwiftData

@Model
public final class Subtask {
    public var id: UUID = UUID()
    public var title: String = ""
    public var isCompleted: Bool = false
    public var sortOrder: Int = 0
    public var goal: Goal?

    public init(title: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.sortOrder = sortOrder
    }
    
    // CloudKit-compatible initializer
    public init() {
        self.id = UUID()
        self.title = ""
        self.isCompleted = false
        self.sortOrder = 0
    }

    public func toggle() {
        isCompleted.toggle()
        goal?.updatedAt = Date()
    }
}
