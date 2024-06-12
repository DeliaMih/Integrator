//
//  Integrator + Notifications.swift
//
//
//  Created by Baluta Eugen on 08.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation
import UserNotifications

import IntegratorDefaults

// MARK: - Local notifications
extension Integrator: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        Constants.ud.purchasePathNotification = "Notifications-->"
        completionHandler()
    }
    
    func removeLocalNotifications(){
        if UserDefaults.standard.bool(forKey: "Notifications") && IntegratorDefaults.isAqcuired {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    func localNotificationsRegister(_ completion: @escaping (Bool) -> Void){
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) { (didAllow, error) in
            completion(didAllow)
        }
    }
    
    func localNotificationsStatus(_ completion: @escaping (UNAuthorizationStatus) -> Void){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            completion(settings.authorizationStatus)
        }
    }
    
    func setupLocalNotifications() {
        UserDefaults.standard.set(true, forKey: "Notifications")
        var notifications = [UNMutableNotificationContent]()
        
        FirebaseWrapper.shared.notifications.forEach { notification in
            notifications.append(
                createLocalNotification(
                    notification.title,
                    subtitle: notification.subtitle,
                    body: notification.body,
                    time: notification.time
                )
            )
        }
        
        (0..<10).forEach { index in
            let time: Double = (Double(index) * 3 * 60 * 60) + 72 * 60 * 60
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: time,
                repeats: false
            )
            
            guard let content = notifications.randomElement() else { return }
            addLocalNotification(content.title, content: content, trigger: trigger)
        }
    }
    
    private func createLocalNotification(
        _ title: String,
        subtitle: String,
        body: String,
        time: Double
    ) -> UNMutableNotificationContent {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        let content = scheduleNotification(title, subtitle: subtitle, body: body)
        let identifier = title
        addLocalNotification(identifier, content: content, trigger: trigger)
        return content
    }
    
    private func addLocalNotification(
        _ identifier: String,
        content: UNNotificationContent,
        trigger: UNTimeIntervalNotificationTrigger
    ) {
        let id = identifier + "-\(Int.random(in: 0...Int.max))"
        let request = UNNotificationRequest(identifier: id,
                                            content: content,
                                            trigger: trigger)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if let error = error {
                debugPrint("Error: \(#file) \(#line)")
                debugPrint("Error \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleNotification(
        _ title: String,
        subtitle: String,
        body: String
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = UNNotificationSound.default
        return content
    }
}
