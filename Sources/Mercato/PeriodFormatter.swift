import Foundation

public enum PeriodFormatter: Sendable {
    public static let `default`: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }()

    public static func format(unit: NSCalendar.Unit, numberOfUnits: Int) -> String? {
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        `default`.allowedUnits = [unit]

        switch unit {
        case .day:
            dateComponents.setValue(numberOfUnits, for: .day)
        case .weekOfMonth:
            dateComponents.setValue(numberOfUnits, for: .weekOfMonth)
        case .month:
            dateComponents.setValue(numberOfUnits, for: .month)
        case .year:
            dateComponents.setValue(numberOfUnits, for: .year)
        default:
            return nil
        }

        return `default`.string(from: dateComponents)
    }
}

