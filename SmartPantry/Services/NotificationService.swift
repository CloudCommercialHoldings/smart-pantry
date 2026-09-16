import Foundation
import UserNotifications

public class NotificationService {
    public static let shared = NotificationService()
    
    public init() {}
    
    /// Requests push notification authorization from the user
    public func requestAuthorization(completion: @escaping (Bool) -> Void = { _ in }) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    /// Schedules local notifications for a pantry item (2 days before, 1 day before, and day of expiration)
    public func scheduleNotifications(for item: PantryItem) {
        guard !item.isConsumed else { return }
        
        let center = UNUserNotificationCenter.current()
        // Remove existing notifications for this item ID
        center.removePendingNotificationRequests(withIdentifiers: [
            "\(item.id.uuidString)-2days",
            "\(item.id.uuidString)-1day",
            "\(item.id.uuidString)-today"
        ])
        
        let calendar = Calendar.current
        let expDate = item.expirationDate
        
        // 2 Days Before Expiration at 9:00 AM
        if let targetDate2 = calendar.date(byAdding: .day, value: -2, to: expDate), targetDate2 > Date() {
            scheduleNotification(
                id: "\(item.id.uuidString)-2days",
                title: "Expiring Soon: \(item.name)",
                body: "\(item.name) in your \(item.location.rawValue) expires in 2 days. Plan to use it!",
                date: targetDate2
            )
        }
        
        // 1 Day Before Expiration at 9:00 AM
        if let targetDate1 = calendar.date(byAdding: .day, value: -1, to: expDate), targetDate1 > Date() {
            scheduleNotification(
                id: "\(item.id.uuidString)-1day",
                title: "Urgent: \(item.name) Expires Tomorrow!",
                body: "Your \(item.name) (\(item.location.rawValue)) expires tomorrow.",
                date: targetDate1
            )
        }
        
        // Day of Expiration at 9:00 AM
        if expDate > Date() {
            scheduleNotification(
                id: "\(item.id.uuidString)-today",
                title: "Expires Today: \(item.name)",
                body: "\(item.name) in your \(item.location.rawValue) expires today. Use or freeze it!",
                date: expDate
            )
        }
    }
    
    /// Cancels all scheduled notifications for a specific item
    public func cancelNotifications(for itemID: UUID) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            "\(itemID.uuidString)-2days",
            "\(itemID.uuidString)-1day",
            "\(itemID.uuidString)-today"
        ])
    }
    
    private func scheduleNotification(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 9
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
}
