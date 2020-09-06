//
//  NotificationManager.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-27.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager(using: .current())
    
    private let center: UNUserNotificationCenter
    
    init(using center: UNUserNotificationCenter) {
        self.center = center
    }
    
    func unregister(id: UUID) {
        self.center.removePendingNotificationRequests(
            withIdentifiers: [id.uuidString]
        )
    }
    
    func register(_ event: Event, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        self.center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard granted else {
                completion(.success(false))
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Countdown complete!"
            content.body = "The countdown to \(event.name) is complete! \(event.emoji)"
            content.categoryIdentifier = "countdown"
            #if os(iOS)
            content.sound = UNNotificationSound(
                named: UNNotificationSoundName("Success 1.caf")
            )
            #endif
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: event.end
                ),
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: event.id.uuidString,
                content: content,
                trigger: trigger
            )
            
            self.center.add(request) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        }
    }
}
