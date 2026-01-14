# WhatsNext

WhatsNext is a modern goal-tracking application available for both **macOS** and **iOS**. Built with SwiftUI and SwiftData, it features a streamlined interface, natural language parsing for quick entry, and powerful organization tools to help you focus on what truly matters. Your goals sync seamlessly between devices using iCloud CloudKit.

## Key Features

### Cross-Platform Sync
- **iCloud CloudKit Integration**: Your goals automatically sync between macOS and iOS devices
- **Real-time Updates**: Changes made on one device appear on all your devices within seconds
- **Shared Data Models**: Both apps use the same SwiftData models for consistent data structure

### Core Features
- **Intuitive Dashboard**: A clean, focused view of your daily, weekly, and monthly goals
- **Natural Language Parsing**: Create goals quickly by typing phrases like `!high Meeting tomorrow`
- **Multi-view Support**: Switch between Checklist and Kanban board views
- **Smart Reminders**: Automated notifications for morning planning and end-of-day reviews
- **Archive System**: Keep your workspace clean by archiving completed or deferred goals
- **Recurring Goals**: Set up goals that repeat daily, weekly, or monthly
- **Tags & Organization**: Organize goals with tags and filter by category
- **Subtasks**: Break down goals into manageable subtasks

### Platform-Specific Features

#### macOS
- **Global Hotkey**: Access the Quick Entry field from anywhere with `Cmd + Shift + Space`
- **Menu Bar Integration**: Quick access from the menu bar
- **Window Management**: Multiple windows and inspector panels
- **Keyboard Shortcuts**: Full keyboard navigation support

#### iOS
- **Tab-Based Navigation**: Easy access to Today, This Week, This Month, and Later goals
- **Touch-Optimized UI**: Designed for mobile interaction
- **Pull-to-Refresh**: Quick data synchronization
- **Native iOS Design**: Follows iOS Human Interface Guidelines

## Architecture

The project follows a modular architecture designed for maintainability and scalability:

### Shared Package (`WhatsNextShared`)

A Swift Package containing all shared code between macOS and iOS:

- **Models**: SwiftData-powered models with CloudKit compatibility
  - `Goal`: Main goal/task entity
  - `Subtask`: Break down goals into smaller tasks
  - `Tag`: Organize goals with tags
  - `GoalAlert`: Reminders and notifications
  - `RecurrenceRule`: Recurring goal patterns
  - `HistoryEntry`: Track goal changes over time
  - `Note`: Rich text notes with bidirectional goal linking
- **Services**: Platform-agnostic business logic
  - `GoalDataService`: Optimized database queries with pagination
  - `NotificationService`: Handles local notifications
  - `NaturalLanguageParser`: Parses natural language for quick goal entry
- **Utilities**: Shared utilities and helpers
  - `Logger`: Centralized logging system
  - `ErrorHandler`: Structured error handling
  - `InputValidator`: Input validation utilities
  - `PaginationHelper`: Pagination state management
  - `SearchDebouncer`: Search input debouncing
  - `Constants`: Application-wide constants

See [WhatsNextShared/README.md](WhatsNextShared/README.md) for detailed package documentation.

### Platform-Specific
- **macOS Views**: `NavigationSplitView`, menu bar integration, global hotkeys
- **iOS Views**: `TabView`, `NavigationStack`, touch-optimized controls
- **ViewModels** (iOS): `GoalListViewModel`, `KanbanViewModel` for business logic separation
- **Platform Services**: Platform-specific services (e.g., `NoteService`, `TagService`, `SyncService` on macOS)

### Data Persistence
- **SwiftData**: Modern data persistence framework
- **CloudKit**: Automatic iCloud sync between devices
- **Shared Container**: Both apps use `iCloud.com.chandi.WhatsNext` container
- **Schema Compatibility**: All models configured for CloudKit with default values and proper relationships

## Requirements

### macOS App
- **macOS 14.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- **Paid Apple Developer Account** (for CloudKit)

### iOS App
- **iOS 18.0+**
- **Xcode 16.0+**
- **Swift 5.9+**
- **Paid Apple Developer Account** (for CloudKit)

## Project Structure

```
App1/
├── WhatsNext/                    # macOS App
│   ├── WhatsNext.xcodeproj
│   └── WhatsNext/
│       ├── Views/               # SwiftUI views (macOS-specific)
│       ├── Services/            # Platform-specific services
│       ├── Components/          # Reusable components
│       └── Resources/            # Assets, icons
│
├── WhatsNextiOSApp/             # iOS App
│   ├── WhatsNextiOSApp.xcodeproj
│   └── WhatsNextiOS/
│       ├── Views/               # iOS-specific views
│       ├── ViewModels/          # MVVM view models
│       ├── Services/            # Platform-specific services
│       ├── Components/          # Reusable components
│       └── Resources/           # Assets, icons
│
├── WhatsNextShared/              # Shared Swift Package
│   ├── Package.swift
│   ├── Sources/
│   │   └── WhatsNextShared/
│   │       ├── Models/          # SwiftData models
│   │       ├── Services/        # Shared business logic
│   │       └── Utilities/       # Shared utilities
│   └── Tests/                   # Unit tests
│
└── README.md
```

## Getting Started

### macOS App

1. Clone the repository
2. Open `WhatsNext/WhatsNext.xcodeproj` in Xcode
3. Select the `WhatsNext` scheme
4. Build and run (⌘ + R)

### iOS App

1. Clone the repository
2. Open `WhatsNextiOSApp/WhatsNextiOSApp.xcodeproj` in Xcode
3. Select the `WhatsNextiOSApp` scheme
4. Choose a simulator or connected iOS device (iOS 18.0+)
5. Build and run (⌘ + R)

### CloudKit Setup

Both apps are pre-configured for CloudKit sync. To enable sync:

1. **Sign in to iCloud**: Ensure you're signed in to the same Apple ID on both devices
2. **Enable CloudKit**: The apps automatically use CloudKit when available
3. **Verify Sync**: Create a goal on one device and it should appear on the other within 30-60 seconds

**Note**: CloudKit requires a paid Apple Developer account. The apps will fall back to local storage if CloudKit is unavailable.

## Data Models

All models are designed for CloudKit compatibility:

- **Default Values**: All non-optional properties have default values
- **No Unique Constraints**: CloudKit doesn't support unique constraints
- **Transient Properties**: Computed properties marked with `@Transient`
- **Relationships**: Properly configured with inverse relationships

### Model Schema

```swift
Schema([
    Goal.self,           // Main goal/task entity
    Subtask.self,        // Subtasks for goals
    Tag.self,            // Tags for organization
    GoalAlert.self,      // Reminders and notifications
    RecurrenceRule.self, // Recurring patterns
    HistoryEntry.self   // Change history
])
```

## Testing

Both apps include comprehensive test suites:

- **Unit Tests**: Model validation, parsing logic, service tests
- **UI Tests**: Component consistency, layout validation
- **Test Plans**: Configured in Xcode for easy test execution

Run tests with `⌘ + U` in Xcode.

## Recent Updates

### CloudKit Integration
- ✅ Full CloudKit sync between macOS and iOS
- ✅ Shared data container (`iCloud.com.chandi.WhatsNext`)
- ✅ Automatic fallback to local storage if CloudKit unavailable
- ✅ Robust error handling and diagnostics

### iOS App
- ✅ Complete iOS app with modern SwiftUI interface
- ✅ Tab-based navigation optimized for mobile
- ✅ MVVM architecture with ViewModels and Data Services
- ✅ Optimized database queries with predicates
- ✅ Touch-friendly UI following iOS design guidelines

### Schema Updates
- ✅ All models updated for CloudKit compatibility
- ✅ Default values for all non-optional properties
- ✅ Transient properties for computed values
- ✅ Proper relationship configuration

### Performance
- ✅ Database-level filtering (10-50x faster queries)
- ✅ Optimized Kanban board loading
- ✅ Efficient data service layer
- ✅ Pagination support for large datasets

### Code Quality
- ✅ Centralized logging system
- ✅ Structured error handling
- ✅ Input validation
- ✅ Comprehensive test coverage
- ✅ Shared package architecture for code reuse

## Development

### Code Style
- SwiftUI best practices
- MVVM pattern (iOS)
- Modular architecture
- Comprehensive documentation

### Dependencies
- **SwiftUI**: UI framework
- **SwiftData**: Data persistence
- **CloudKit**: iCloud sync
- **UserNotifications**: Local notifications
- **WhatsNextShared**: Local Swift Package containing shared models, services, and utilities

## License

See LICENSE file for details.

---

Built with ❤️ by **Chandi Kodthiwada**  
[Linkedin](https://www.linkedin.com/in/chandikodthiwada/) | [Github](https://github.com/IamChandi)
