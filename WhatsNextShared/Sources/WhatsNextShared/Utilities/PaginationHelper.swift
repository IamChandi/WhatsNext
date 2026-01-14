//
//  PaginationHelper.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation

/// Helper class for managing pagination state.
@MainActor
public final class PaginationHelper {
    /// Current page number (0-indexed)
    public private(set) var currentPage: Int = 0
    
    /// Number of items per page
    public let pageSize: Int
    
    /// Total number of items available
    public private(set) var totalItems: Int = 0
    
    /// Whether there are more items to load
    public var hasMore: Bool {
        (currentPage + 1) * pageSize < totalItems
    }
    
    /// Whether we're currently loading
    public private(set) var isLoading: Bool = false
    
    /// Current offset for fetching
    public var offset: Int {
        currentPage * pageSize
    }
    
    public init(pageSize: Int = AppConstants.Pagination.defaultPageSize) {
        self.pageSize = max(
            AppConstants.Pagination.minPageSize,
            min(pageSize, AppConstants.Pagination.maxPageSize)
        )
    }
    
    /// Updates the total item count
    public func updateTotalItems(_ count: Int) {
        totalItems = count
    }
    
    /// Moves to the next page
    public func nextPage() {
        guard hasMore else { return }
        currentPage += 1
    }
    
    /// Moves to the previous page
    public func previousPage() {
        guard currentPage > 0 else { return }
        currentPage -= 1
    }
    
    /// Resets to the first page
    public func reset() {
        currentPage = 0
        totalItems = 0
    }
    
    /// Sets loading state
    public func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    /// Calculates the total number of pages
    public var totalPages: Int {
        guard pageSize > 0 else { return 0 }
        return Int(ceil(Double(totalItems) / Double(pageSize)))
    }
    
    /// Whether we're on the first page
    public var isFirstPage: Bool {
        currentPage == 0
    }
    
    /// Whether we're on the last page
    public var isLastPage: Bool {
        !hasMore
    }
}
