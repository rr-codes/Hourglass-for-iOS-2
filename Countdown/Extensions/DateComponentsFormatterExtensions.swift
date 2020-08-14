//
//  DateComponentsFormatterExtensions.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-10.
//

import Foundation

extension DateComponentsFormatter {
    func string(from dates: (start: Date, end: Date), numberOfDroppedUnits n: Int, using calendar: Calendar) -> String? {
        let inOneDay  = calendar.date(byAdding: .day, value: 1, to: dates.start)!
        let inOneHour = calendar.date(byAdding: .hour, value: 1, to: dates.start)!
        let inOneMin  = calendar.date(byAdding: .minute, value: 1, to: dates.start)!
        
        let oneDayAgo  = calendar.date(byAdding: .day, value: -1, to: dates.start)!
        let oneHourAgo = calendar.date(byAdding: .hour, value: -1, to: dates.start)!
        let oneMinAgo  = calendar.date(byAdding: .minute, value: -1, to: dates.start)!
                
        var units: [NSCalendar.Unit] = [.day, .hour, .minute, .second]
        
        if oneDayAgo...inOneDay ~= dates.end {
            units.removeFirst()
        }
        
        if oneHourAgo...inOneHour ~= dates.end {
            units.removeFirst()
        }
        
        if oneMinAgo...inOneMin ~= dates.end {
            units.removeFirst()
        }
        
        self.allowedUnits = .init(units.dropFirst(n % units.count))
        return self.string(from: dates.end.timeIntervalSince(dates.start))
    }
}
