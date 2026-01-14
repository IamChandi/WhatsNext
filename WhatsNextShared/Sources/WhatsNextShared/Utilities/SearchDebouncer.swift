//
//  SearchDebouncer.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation
import Combine

/// Debounces search text input to reduce unnecessary filtering operations.
@MainActor
public final class SearchDebouncer: ObservableObject {
    @Published public var searchText: String = ""
    @Published public var debouncedSearchText: String = ""
    
    private nonisolated(unsafe) var cancellable: AnyCancellable?
    private let debounceInterval: TimeInterval
    
    public init(debounceInterval: TimeInterval = AppConstants.Timing.searchDebounce) {
        self.debounceInterval = debounceInterval
        
        cancellable = $searchText
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main)
            .assign(to: \.debouncedSearchText, on: self)
    }
    
    deinit {
        cancellable?.cancel()
    }
}
