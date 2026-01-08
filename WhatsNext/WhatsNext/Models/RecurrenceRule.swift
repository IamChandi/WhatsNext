import Foundation
import SwiftData

@Model
final class RecurrenceRule {
    var id: UUID = UUID()
    var patternRaw: String = RecurrencePattern.daily.rawValue
    var interval: Int = 1
    var daysOfWeekRaw: String? // Store as comma-separated string instead of [Int]
    var dayOfMonth: Int?
    var endDate: Date?
    var goal: Goal?
    
    @Transient
    var daysOfWeek: [Int]? {
        get {
            guard let raw = daysOfWeekRaw, !raw.isEmpty else { return nil }
            return raw.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        }
        set {
            daysOfWeekRaw = newValue?.map { String($0) }.joined(separator: ",")
        }
    }

    @Transient
    var pattern: RecurrencePattern {
        get { RecurrencePattern(rawValue: patternRaw) ?? .daily }
        set { patternRaw = newValue.rawValue }
    }

    init(
        pattern: RecurrencePattern,
        interval: Int = 1,
        daysOfWeek: [Int]? = nil,
        dayOfMonth: Int? = nil,
        endDate: Date? = nil
    ) {
        self.id = UUID()
        self.patternRaw = pattern.rawValue
        self.interval = interval
        self.daysOfWeekRaw = daysOfWeek?.map { String($0) }.joined(separator: ",")
        self.dayOfMonth = dayOfMonth
        self.endDate = endDate
    }
    
    // CloudKit-compatible initializer
    init() {
        self.id = UUID()
        self.patternRaw = RecurrencePattern.daily.rawValue
        self.interval = 1
    }

    func nextOccurrence(from date: Date) -> Date? {
        let calendar = Calendar.current

        if let endDate = endDate, date >= endDate {
            return nil
        }

        switch pattern {
        case .daily:
            return calendar.date(byAdding: .day, value: interval, to: date)

        case .weekly:
            if let days = daysOfWeek, !days.isEmpty {
                let currentWeekday = calendar.component(.weekday, from: date)
                let sortedDays = days.sorted()

                if let nextDay = sortedDays.first(where: { $0 > currentWeekday }) {
                    let daysToAdd = nextDay - currentWeekday
                    return calendar.date(byAdding: .day, value: daysToAdd, to: date)
                } else if let firstDay = sortedDays.first {
                    let daysToAdd = (7 - currentWeekday) + firstDay + (7 * (interval - 1))
                    return calendar.date(byAdding: .day, value: daysToAdd, to: date)
                }
            }
            return calendar.date(byAdding: .weekOfYear, value: interval, to: date)

        case .monthly:
            if let day = dayOfMonth {
                var components = calendar.dateComponents([.year, .month], from: date)
                components.day = day
                if let nextMonth = calendar.date(byAdding: .month, value: interval, to: date) {
                    components = calendar.dateComponents([.year, .month], from: nextMonth)
                    components.day = min(day, calendar.range(of: .day, in: .month, for: nextMonth)?.count ?? day)
                    return calendar.date(from: components)
                }
            }
            return calendar.date(byAdding: .month, value: interval, to: date)

        case .custom:
            return calendar.date(byAdding: .day, value: interval, to: date)
        }
    }

    @Transient
    var displayDescription: String {
        switch pattern {
        case .daily:
            return interval == 1 ? "Every day" : "Every \(interval) days"
        case .weekly:
            if interval == 1 {
                if let days = daysOfWeek, !days.isEmpty {
                    let dayNames = days.compactMap { dayName(for: $0) }
                    return "Every \(dayNames.joined(separator: ", "))"
                }
                return "Every week"
            }
            return "Every \(interval) weeks"
        case .monthly:
            if interval == 1 {
                if let day = dayOfMonth {
                    return "Monthly on day \(day)"
                }
                return "Every month"
            }
            return "Every \(interval) months"
        case .custom:
            return "Every \(interval) days"
        }
    }

    private func dayName(for weekday: Int) -> String? {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        guard weekday >= 1, weekday <= 7 else { return nil }
        return formatter.shortWeekdaySymbols[weekday - 1]
    }
}
