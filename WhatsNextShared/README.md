# WhatsNextShared

Shared code package for WhatsNext macOS and iOS applications.

## Overview

This Swift Package contains all shared code between the macOS and iOS versions of WhatsNext, including:

- **Models**: SwiftData models (Goal, Note, Tag, etc.)
- **Services**: Business logic services (GoalDataService, NotificationService, NoteService, etc.)
- **Utilities**: Common utilities (Logger, ErrorHandler, Constants, InputValidator, PaginationHelper, etc.)

## Features

- ✅ **Database-level filtering** for optimal performance
- ✅ **Pagination support** for large datasets
- ✅ **Input validation** for data integrity
- ✅ **Centralized error handling** with user-friendly messages
- ✅ **Comprehensive logging** with categorized loggers
- ✅ **CloudKit sync** support
- ✅ **Type-safe enums** for categories, priorities, and statuses

## Structure

```
WhatsNextShared/
├── Sources/
│   └── WhatsNextShared/
│       ├── Models/          # SwiftData models
│       ├── Services/        # Business logic services
│       └── Utilities/       # Shared utilities
└── Tests/
    └── WhatsNextSharedTests/ # Unit tests
```

## Usage

### Adding to Xcode Project

1. In Xcode, go to **File > Add Package Dependencies...**
2. Select **Add Local...**
3. Navigate to the `WhatsNextShared` directory
4. Click **Add Package**

### Importing in Code

```swift
import WhatsNextShared

// Use shared models
let goal = Goal(title: "My Goal", category: .daily)

// Use shared services
let service = GoalDataService(modelContext: modelContext)
let goals = try service.fetchGoals(category: .daily)

// Use shared utilities
Logger.app.info("Application started")
```

## Requirements

- macOS 14.0+ / iOS 18.0+
- Swift 5.9+
- Xcode 15.0+

## Testing

Run tests with:

```bash
swift test
```

Or in Xcode: **Product > Test** (⌘U)

## Migration Notes

When migrating from duplicated code:

1. Remove duplicate files from app targets
2. Add WhatsNextShared package dependency
3. Update imports from local files to `import WhatsNextShared`
4. Test thoroughly on both platforms

## Platform-Specific Code

Some code uses conditional compilation for platform differences:

```swift
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
```

This allows the same code to work on both macOS and iOS.

## API Documentation

### GoalDataService

Service for efficient data access and querying of goals.

**Key Methods:**
- `fetchGoals(category:searchText:excludeArchived:limit:offset:)` - Fetch goals with pagination
- `fetchAllGoals(excludeArchived:searchText:limit:offset:)` - Fetch all goals across categories
- `countGoals(category:searchText:excludeArchived:)` - Count matching goals
- `fetchArchivedGoals(searchText:limit:offset:)` - Fetch archived goals

**Example:**
```swift
let service = GoalDataService(modelContext: modelContext)

// Fetch first page of daily goals
let goals = try service.fetchGoals(
    category: .daily,
    limit: 50,
    offset: 0
)

// Get total count for pagination
let totalCount = try service.countGoals(category: .daily)
```

### InputValidator

Centralized input validation utilities.

**Key Methods:**
- `validateTitle(_:)` - Validate goal titles
- `validateNoteSize(_:)` - Validate note content size (1MB limit)
- `validateDateRange(start:end:)` - Validate date ranges
- `sanitize(_:)` - Sanitize user input

**Example:**
```swift
if let error = InputValidator.validateTitle(goalTitle) {
    // Handle validation error
    print(error.localizedDescription)
}
```

### PaginationHelper

Helper for managing pagination state.

**Example:**
```swift
let pagination = PaginationHelper(pageSize: 50)
pagination.updateTotalItems(1000)

// Load next page
pagination.nextPage()
let offset = pagination.offset
let goals = try service.fetchGoals(category: .daily, limit: 50, offset: offset)
```

### Logger

Categorized logging system using `os.log`.

**Categories:**
- `Logger.data` - Data persistence operations
- `Logger.ui` - UI updates and interactions
- `Logger.network` - Network and CloudKit operations
- `Logger.notifications` - Notification scheduling
- `Logger.app` - App lifecycle events
- `Logger.error` - Errors and exceptions
- `Logger.performance` - Performance metrics

**Example:**
```swift
Logger.data.info("Goal saved successfully")
Logger.error.error("Failed to save: \(error.localizedDescription)")
```

### ErrorHandler

Centralized error handling with user feedback.

**Example:**
```swift
do {
    try modelContext.save()
} catch {
    ErrorHandler.shared.handle(.saveFailed(error), context: "GoalListView.saveGoal")
}
```

## Performance Considerations

- **Database-level filtering**: All queries use SwiftData predicates for optimal performance
- **Pagination**: Use `limit` and `offset` parameters for large datasets
- **Lazy loading**: Views use `LazyVStack`/`LazyHStack` where appropriate
- **Caching**: ViewModels cache expensive computations

## Testing

The package includes comprehensive tests:

- **Unit tests** for models, services, and utilities
- **Performance tests** for query operations
- **Validation tests** for input validation

Run tests:
```bash
swift test
```

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture documentation.
