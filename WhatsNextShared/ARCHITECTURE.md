# WhatsNextShared Architecture

## Overview

WhatsNextShared is a Swift Package that provides shared business logic, models, and utilities for both the macOS and iOS versions of WhatsNext. It follows a clean architecture pattern with clear separation of concerns.

## Architecture Layers

```
┌─────────────────────────────────────┐
│         App Layer (Platform)         │
│  (macOS Views / iOS Views)          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      ViewModels (Platform)           │
│  (GoalListViewModel, etc.)           │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Service Layer (Shared)          │
│  (GoalDataService, NoteService)     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Model Layer (Shared)            │
│  (Goal, Note, Tag, etc.)             │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Data Layer (SwiftData)          │
│  (ModelContext, CloudKit)            │
└─────────────────────────────────────┘
```

## Components

### Models

SwiftData models representing the core domain entities:

- **Goal**: Main entity representing a task or goal
- **Note**: Rich text notes associated with goals
- **Subtask**: Subtasks within a goal
- **Tag**: Tags for categorizing goals
- **GoalAlert**: Scheduled reminders
- **RecurrenceRule**: Recurrence patterns for repeating goals
- **HistoryEntry**: Change history tracking

**Design Principles:**
- Use `@Model` macro for SwiftData persistence
- Use raw strings for enum storage (CloudKit compatibility)
- Provide computed properties for type-safe access
- Cascade deletes for related entities

### Services

Business logic services that encapsulate data operations:

#### GoalDataService
- Efficient goal fetching with database-level filtering
- Pagination support
- Search functionality
- Category-based queries

#### NotificationService
- Local notification scheduling
- Daily reminder management
- Notification permission handling

#### NoteService
- Note CRUD operations
- Content size validation
- Rich text handling

#### AnalyticsService
- Analytics calculations
- Streak tracking
- Completion statistics

#### TagService
- Tag management
- Color handling
- Goal-tag associations

#### SyncService
- CloudKit sync monitoring
- Sync status tracking

**Design Principles:**
- All services are `@MainActor` for thread safety
- Use `FetchDescriptor` with predicates for queries
- Return typed errors instead of throwing generic errors
- Support pagination for large datasets

### Utilities

Shared utilities for common operations:

#### Logger
Categorized logging system using `os.log`:
- `data`: Data persistence operations
- `ui`: UI updates
- `network`: Network operations
- `notifications`: Notification scheduling
- `app`: App lifecycle
- `error`: Errors
- `performance`: Performance metrics

#### ErrorHandler
Centralized error handling:
- `AppError` enum for typed errors
- User-friendly error messages
- Error recovery suggestions
- View modifier for error display

#### InputValidator
Input validation utilities:
- Title validation
- Note size validation (1MB limit)
- Date range validation
- Input sanitization

#### PaginationHelper
Pagination state management:
- Page tracking
- Offset calculation
- Has more items detection

#### Constants
Application-wide constants:
- Animation durations
- Timing delays
- Data limits
- Pagination settings

#### ModelContextExtensions
Extensions for `ModelContext`:
- `saveWithErrorHandling()` - Save with error logging
- `saveOrThrow()` - Save with explicit error throwing

## Data Flow

### Reading Data

1. **View** requests data from **ViewModel**
2. **ViewModel** calls **Service** method
3. **Service** creates `FetchDescriptor` with predicates
4. **Service** executes query on `ModelContext`
5. Results returned to **ViewModel**
6. **ViewModel** updates `@Published` properties
7. **View** automatically updates via SwiftUI

### Writing Data

1. **View** triggers action (user interaction)
2. **ViewModel** or **View** modifies model
3. **ModelContext** tracks changes
4. **Service** or **View** calls `saveWithErrorHandling()`
5. **ErrorHandler** handles any errors
6. **View** updates to reflect changes

## Performance Optimizations

### Database-Level Filtering
All queries use SwiftData predicates to filter at the database level, not in memory:

```swift
let predicate = #Predicate<Goal> { goal in
    goal.categoryRaw == category.rawValue &&
    goal.statusRaw != "archived"
}
```

### Pagination
Large datasets are paginated to reduce memory usage:

```swift
let goals = try service.fetchGoals(
    category: .daily,
    limit: 50,
    offset: 0
)
```

### Lazy Loading
Views use `LazyVStack`/`LazyHStack` for large lists.

### Caching
ViewModels cache expensive computations and only recalculate when dependencies change.

## Error Handling Strategy

1. **Service Layer**: Services throw typed errors
2. **ViewModel Layer**: ViewModels catch errors and update state
3. **View Layer**: Views use `ErrorHandler` for user-facing errors
4. **Logging**: All errors are logged with context

## Testing Strategy

- **Unit Tests**: Test individual components in isolation
- **Performance Tests**: Measure query performance and memory usage
- **Integration Tests**: Test service interactions with SwiftData

## Platform Compatibility

The package uses conditional compilation for platform-specific code:

```swift
#if canImport(AppKit)
// macOS-specific code
#elseif canImport(UIKit)
// iOS-specific code
#endif
```

This allows the same codebase to work on both platforms while maintaining platform-specific optimizations.

## Future Improvements

- [ ] Add more comprehensive performance tests
- [ ] Implement query result caching
- [ ] Add batch operations for bulk updates
- [ ] Implement offline-first sync strategy
- [ ] Add data migration utilities
