//
//  SearchDebouncer.swift
//  WhatsNext
//
//  Utility for debouncing search input to improve performance.
//

import Foundation
import WhatsNextShared
import Combine
import WhatsNextShared

/// Debounces search text input to reduce unnecessary filtering operations.
@MainActor
final class SearchDebouncer: ObservableObject {
    @Published var searchText: String = ""
    @Published var debouncedSearchText: String = ""
    
    private var cancellable: AnyCancellable?
    private let debounceInterval: TimeInterval
    
    init(debounceInterval: TimeInterval = AppConstants.Timing.searchDebounce) {
        self.debounceInterval = debounceInterval
        
        cancellable = $searchText
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main)
            .assign(to: \.debouncedSearchText, on: self)
    }
    
    deinit {
        cancellable?.cancel()
    }
}
