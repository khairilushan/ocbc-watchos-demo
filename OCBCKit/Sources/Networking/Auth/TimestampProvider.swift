import Foundation

public protocol TimestampProvider: Sendable {
    func now() -> Date
    func string(from date: Date) -> String
}

public struct DefaultTimestampProvider: TimestampProvider {
    public init() {}

    public func now() -> Date {
        Date()
    }

    public func string(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE MMM dd HH:mm:ss 'GMT'XXXXX yyyy"
        return formatter.string(from: date)
    }
}
