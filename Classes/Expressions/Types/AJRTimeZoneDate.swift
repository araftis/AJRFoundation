/*
 AJRTimeZoneDate.swift
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRFoundation nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation

public struct AJRTimeZoneDate : Comparable, Equatable, Hashable, AJREquatable {
    
    var date: Date
    var timeZone: TimeZone
    
    /// Returns a `Date` initialized to the current date and time in the current time zone.
    public init(timeZone: TimeZone? = nil) {
        self.date = Date()
        self.timeZone = timeZone ?? TimeZone.current
    }
    
    public init(date: Date, timeZone: TimeZone? = nil) {
        self.date = date
        self.timeZone = timeZone ?? TimeZone.current
    }
    
    /// Returns a `Date` initialized relative to the current date and time by a given number of seconds.
    public init(timeIntervalSinceNow: TimeInterval, timeZone: TimeZone? = nil) {
        self.date = Date(timeIntervalSinceNow: timeIntervalSinceNow)
        self.timeZone = timeZone ?? TimeZone.current
    }
    
    /// Returns a `Date` initialized relative to 00:00:00 UTC on 1 January 1970 by a given number of seconds.
    public init(timeIntervalSince1970: TimeInterval, timeZone: TimeZone? = nil) {
        self.date = Date(timeIntervalSince1970: timeIntervalSince1970)
        self.timeZone = timeZone ?? TimeZone.current
    }
    
    /**
     Returns a `Date` initialized relative to another given date by a given number of seconds.
     
     - Parameter timeInterval: The number of seconds to add to `date`. A negative value means the receiver will be earlier than `date`.
     - Parameter date: The reference date.
     */
    public init(timeInterval: TimeInterval, since date: Date, timeZone: TimeZone? = nil) {
        self.date = Date(timeInterval: timeInterval, since: date)
        self.timeZone = timeZone ?? TimeZone.current
    }
    
    /// Returns a `Date` initialized relative to 00:00:00 UTC on 1 January 2001 by a given number of seconds.
    public init(timeIntervalSinceReferenceDate ti: TimeInterval, timeZone: TimeZone? = nil) {
        self.date = Date(timeIntervalSinceReferenceDate: ti)
        self.timeZone = timeZone ?? TimeZone.current
    }
    
    /// Create a new date represented by UTC time: yyyy-MM-dd'T'HH:mm:ssZZZZZ.
    public init(utc: String) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let newDate = formatter.date(from: utc) {
            var timeZone : TimeZone? = nil
            if utc.count > 5 {
                let tzSubstring = utc[utc.index(utc.endIndex, offsetBy: -5) ..< utc.endIndex]
                if let offset = Int(tzSubstring) {
                    if let possibleTimeZone = TimeZone(secondsFromGMT: ((offset / 100) * 60 * 60) + ((offset % 100) * 60)) {
                        timeZone = possibleTimeZone
                    } else {
                        throw DateError.invalidFormat("Bad time zone")
                    }
                }
            }
            self.init(timeIntervalSinceReferenceDate: newDate.timeIntervalSinceReferenceDate, timeZone: timeZone)
        } else {
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let newDate = formatter.date(from: utc) {
                self.init(timeIntervalSinceReferenceDate: newDate.timeIntervalSinceReferenceDate)
            } else {
                formatter.dateFormat = "yyyy-MM-dd"
                if let newDate = formatter.date(from: utc) {
                    self.init(timeIntervalSinceReferenceDate: newDate.timeIntervalSinceReferenceDate)
                } else {
                    throw DateError.invalidFormat("Input isn't valid UTC: \(utc)")
                }
            }
        }
    }
    
    /**
     Returns the interval between the date object and 00:00:00 UTC on 1 January 2001.
     
     This property's value is negative if the date object is earlier than the system's absolute reference date (00:00:00 UTC on 1 January 2001).
     */
    public var timeIntervalSinceReferenceDate: TimeInterval {
        return date.timeIntervalSinceReferenceDate
    }
    
    /**
     Returns the interval between the receiver and another given date.
     
     - Parameter another: The date with which to compare the receiver.
     
     - Returns: The interval between the receiver and the `another` parameter. If the receiver is earlier than `anotherDate`, the return value is negative. If `anotherDate` is `nil`, the results are undefined.
     
     - SeeAlso: `timeIntervalSince1970`
     - SeeAlso: `timeIntervalSinceNow`
     - SeeAlso: `timeIntervalSinceReferenceDate`
     */
    public func timeIntervalSince(_ date: Date) -> TimeInterval {
        return date.timeIntervalSince(date)
    }
    
    public func timeIntervalSince(_ date: AJRTimeZoneDate) -> TimeInterval {
        return date.timeIntervalSince(date.date)
    }
    
    /**
     The time interval between the date and the current date and time.
     
     If the date is earlier than the current date and time, this property's value is negative.
     
     - SeeAlso: `timeIntervalSince(_:)`
     - SeeAlso: `timeIntervalSince1970`
     - SeeAlso: `timeIntervalSinceReferenceDate`
     */
    public var timeIntervalSinceNow: TimeInterval {
        return date.timeIntervalSinceNow
    }
    
    /**
     The interval between the date object and 00:00:00 UTC on 1 January 1970.
     
     This property's value is negative if the date object is earlier than 00:00:00 UTC on 1 January 1970.
     
     - SeeAlso: `timeIntervalSince(_:)`
     - SeeAlso: `timeIntervalSinceNow`
     - SeeAlso: `timeIntervalSinceReferenceDate`
     */
    public var timeIntervalSince1970: TimeInterval {
        return date.timeIntervalSince1970
    }
    
    /// Return a new `Date` by adding a `TimeInterval` to this `Date`.
    ///
    /// - parameter timeInterval: The value to add, in seconds.
    /// - warning: This only adjusts an absolute value. If you wish to add calendrical concepts like hours, days, months then you must use a `Calendar`. That will take into account complexities like daylight saving time, months with different numbers of days, and more.
    public func addingTimeInterval(_ timeInterval: TimeInterval) -> AJRTimeZoneDate {
        return AJRTimeZoneDate(date: date.addingTimeInterval(timeInterval), timeZone: timeZone)
    }
    
    /// Add a `TimeInterval` to this `Date`.
    ///
    /// - parameter timeInterval: The value to add, in seconds.
    /// - warning: This only adjusts an absolute value. If you wish to add calendrical concepts like hours, days, months then you must use a `Calendar`. That will take into account complexities like daylight saving time, months with different numbers of days, and more.
    public mutating func addTimeInterval(_ timeInterval: TimeInterval) {
        date.addTimeInterval(timeInterval)
    }
    
    /**
     Creates and returns a Date value representing a date in the distant future.
     
     The distant future is in terms of centuries.
     */
    public static let distantFuture: AJRTimeZoneDate = {
        return AJRTimeZoneDate(date: Date.distantFuture)
    }()
    
    /**
     Creates and returns a Date value representing a date in the distant past.
     
     The distant past is in terms of centuries.
     */
    public static let distantPast: AJRTimeZoneDate = {
        return AJRTimeZoneDate(date: Date.distantPast)
    }()
    
    /**
     Add our hash value to `hasher`.

     Hash values are not guaranteed to be equal across different executions of your program. Do not save hash values to use during a future execution.
     */
    public func hash(into hasher: inout Hasher) {
        date.hash(into: &hasher)
        timeZone.hash(into: &hasher)
    }
    
    /// Compare two `Date` values.
    public func compare(_ other: AJRTimeZoneDate) -> ComparisonResult {
        return date.compare(other.date)
    }
    
    public func compare(_ other: Date) -> ComparisonResult {
        return date.compare(other)
    }
    
    public func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRTimeZoneDate {
            return self == other
        } else if let otherDate = other as? Date {
            return self == otherDate
        }
        return false
    }
    
    /// Returns true if the two `Date` values represent the same point in time.
    public static func == (lhs: AJRTimeZoneDate, rhs: AJRTimeZoneDate) -> Bool {
        return lhs.date == rhs.date && lhs.timeZone == rhs.timeZone
    }
    
    // Note 100% sure I want this yet, but going with it for now.
    public static func == (lhs: Date, rhs: AJRTimeZoneDate) -> Bool {
        return lhs == rhs.date
    }
    
    public static func == (lhs: AJRTimeZoneDate, rhs: Date) -> Bool {
        return lhs.date == rhs
    }
    
    /// Returns true if the left hand `Date` is earlier in time than the right hand `Date`.
    public static func < (lhs: AJRTimeZoneDate, rhs: AJRTimeZoneDate) -> Bool {
        return lhs.date < rhs.date
    }
    
    public static func < (lhs: Date, rhs: AJRTimeZoneDate) -> Bool {
        return lhs < rhs.date
    }
    
    public static func < (lhs: AJRTimeZoneDate, rhs: Date) -> Bool {
        return lhs.date < rhs
    }
    
    /// Returns true if the left hand `Date` is later in time than the right hand `Date`.
    public static func > (lhs: AJRTimeZoneDate, rhs: AJRTimeZoneDate) -> Bool {
        return lhs.date > rhs.date
    }
    
    public static func > (lhs: Date, rhs: AJRTimeZoneDate) -> Bool {
        return lhs > rhs.date
    }
    
    public static func > (lhs: AJRTimeZoneDate, rhs: Date) -> Bool {
        return lhs.date > rhs
    }
    
    /// Returns a `Date` with a specified amount of time added to it.
    public static func + (lhs: AJRTimeZoneDate, rhs: TimeInterval) -> AJRTimeZoneDate {
        return AJRTimeZoneDate(date: lhs.date + rhs, timeZone: lhs.timeZone)
    }
    
    /// Returns a `Date` with a specified amount of time subtracted from it.
    public static func - (lhs: AJRTimeZoneDate, rhs: TimeInterval) -> AJRTimeZoneDate {
        return AJRTimeZoneDate(date: lhs.date - rhs, timeZone: lhs.timeZone)
    }
    
    /// Add a `TimeInterval` to a `Date`.
    ///
    /// - warning: This only adjusts an absolute value. If you wish to add calendrical concepts like hours, days, months then you must use a `Calendar`. That will take into account complexities like daylight saving time, months with different numbers of days, and more.
    public static func += (lhs: inout AJRTimeZoneDate, rhs: TimeInterval) {
        lhs = AJRTimeZoneDate(date: lhs.date + rhs, timeZone: lhs.timeZone)
    }
    
    /// Subtract a `TimeInterval` from a `Date`.
    ///
    /// - warning: This only adjusts an absolute value. If you wish to add calendrical concepts like hours, days, months then you must use a `Calendar`. That will take into account complexities like daylight saving time, months with different numbers of days, and more.
    public static func -= (lhs: inout AJRTimeZoneDate, rhs: TimeInterval) {
        lhs = AJRTimeZoneDate(date: lhs.date - rhs, timeZone: lhs.timeZone)
    }
    
}

extension AJRTimeZoneDate : CustomDebugStringConvertible, CustomStringConvertible {
    
    /**
     A string representation of the date object (read-only).
     
     The representation is useful for debugging only.
     
     There are a number of options to acquire a formatted string for a date including: date formatters (see
     [NSDateFormatter](//apple_ref/occ/cl/NSDateFormatter) and [Data Formatting Guide](//apple_ref/doc/uid/10000029i)), and the `Date` function `description(locale:)`.
     */
    public var description: String {
        return description(with: nil)
    }
    

    private static var defaultFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()

    /**
     Returns a string representation of the receiver using the given
     locale.
     
     - Parameter locale: A `Locale`. If you pass `nil`, `Date` formats the date in the same way as the `description` property.
     
     - Returns: A string representation of the `Date`, using the given locale, or if the locale argument is `nil`, in the international format `YYYY-MM-DD HH:MM:SS ±HHMM`, where `±HHMM` represents the time zone offset in hours and minutes from UTC (for example, "`2001-03-24 10:45:32 +0600`").
     */
    public func description(with locale: Locale?) -> String {
        return AJRTimeZoneDate.defaultFormatter.string(from: date)
    }
    
    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(reflecting:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `debugDescription` property for types that conform to
    /// `CustomDebugStringConvertible`:
    ///
    ///     struct Point: CustomDebugStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var debugDescription: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(reflecting: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `debugDescription` property.
    public var debugDescription: String {
        return description(with: nil)
    }
}

extension AJRTimeZoneDate : Codable {
    
    enum CodingKeys: String, CodingKey {
        case date
        case timeZone
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        timeZone = try container.decode(TimeZone.self, forKey: .timeZone)
    }
    
    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(timeZone, forKey: .timeZone)
    }
 
    // MARK: - Methods we extended on Date
    
    public static func dateForStartOfDayLocalTime() -> AJRTimeZoneDate {
        return Calendar.current.startOfDay(for:AJRTimeZoneDate())
    }
    
}

public extension Calendar {
    
    func dateComponents(in timeZone: TimeZone, from date: AJRTimeZoneDate) -> DateComponents {
        return self.dateComponents(in:timeZone, from: date.date)
    }
    
    func dateComponents(from date: AJRTimeZoneDate) -> DateComponents {
        return self.dateComponents(in:date.timeZone, from: date.date)
    }
    
    func dateComponents(_ components: Set<Calendar.Component>, from: AJRTimeZoneDate, to: AJRTimeZoneDate) -> DateComponents {
        let fromComponents = dateComponents(from: from)
        let toComponents = dateComponents(from: to)
        return dateComponents(components, from: fromComponents, to: toComponents)
    }
    
    func date(byAdding components: DateComponents, to date: AJRTimeZoneDate, wrappingComponents: Bool = false) -> AJRTimeZoneDate? {
        if let newDate = self.date(byAdding: components, to: date.date, wrappingComponents: wrappingComponents) {
            return AJRTimeZoneDate(date: newDate, timeZone: date.timeZone)
        }
        return nil
    }
    
    func date(byAdding component: Calendar.Component, value: Int, to date: AJRTimeZoneDate, wrappingComponents: Bool = false) -> AJRTimeZoneDate? {
        if let newDate = self.date(byAdding: component, value: value, to: date.date, wrappingComponents: wrappingComponents) {
            return AJRTimeZoneDate(date: newDate, timeZone: date.timeZone)
        }
        return nil
    }
    
    func date(from components: DateComponents) -> AJRTimeZoneDate? {
        if let newDate : Date = self.date(from: components) {
            return AJRTimeZoneDate(date: newDate, timeZone: components.timeZone)
        }
        return nil
    }
    
    func startOfDay(for date: AJRTimeZoneDate) -> AJRTimeZoneDate {
        var other = self
        other.timeZone = date.timeZone
        return AJRTimeZoneDate(date: other.startOfDay(for: date.date), timeZone: date.timeZone)
    }

}
