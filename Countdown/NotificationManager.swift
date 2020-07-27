//
//  NotificationManager.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-27.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    func unregister(id: UUID) {
        self.center.removePendingNotificationRequests(
            withIdentifiers: [id.uuidString]
        )
    }
    
    func register(config: (name: String, emoji: String, date: Date, id: UUID), _ completion: @escaping (Result<Bool, Error>) -> Void) {
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
            content.body = "The countdown to \(config.name) is complete! \(config.emoji)"
            content.categoryIdentifier = "countdown"
            content.sound = UNNotificationSound(
                named: UNNotificationSoundName("Success 1.caf")
            )
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: config.date
                ),
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: config.id.uuidString,
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
