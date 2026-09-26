import Foundation
import UserNotifications

public class NotificationService {
    public static let shared = NotificationService()
    
    public init() {}
    
    /// Requests push notification authorization from the user
    public func requestAuthorization(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    /// Schedules local notifications for a pantry item
    public func scheduleNotifications(for item: PantryItem) {
        guard !item.isConsumed else { return }
        
        cancelNotifications(for: item.id)
        
        let calendar = Calendar.current
        let expDate = item.expirationDate
        
        // 10 Days Before Expiration
        if let targetDate10 = calendar.date(byAdding: .day, value: -10, to: expDate), targetDate10 > Date() {
            scheduleNotification(
                id: "\(item.id.uuidString)-10days",
                title: "Expiring in 10 Days: \(item.name)",
                body: "Your \(item.name) stored in \(item.location.rawValue) expires in 10 days. Plan your meals!",
                date: targetDate10
            )
        }
        
        // 2 Days Before Expiration
        if let targetDate2 = calendar.date(byAdding: .day, value: -2, to: expDate), targetDate2 > Date() {
            scheduleNotification(
                id: "\(item.id.uuidString)-2days",
                title: "Expiring Soon: \(item.name)",
                body: "\(item.name) in your \(item.location.rawValue) expires in 2 days. Plan to use it!",
                date: targetDate2
            )
        }
        
        // 1 Day Before Expiration
        if let targetDate1 = calendar.date(byAdding: .day, value: -1, to: expDate), targetDate1 > Date() {
            scheduleNotification(
                id: "\(item.id.uuidString)-1day",
                title: "Urgent: \(item.name) Expires Tomorrow!",
                body: "Your \(item.name) (\(item.location.rawValue)) expires tomorrow.",
                date: targetDate1
            )
        }
        
        // Day of Expiration
        if expDate > Date() {
            scheduleNotification(
                id: "\(item.id.uuidString)-today",
                title: "Expires Today: \(item.name)",
                body: "\(item.name) in your \(item.location.rawValue) expires today. Use or freeze it!",
                date: expDate
            )
        }
        
        // Special Freezer Push Notification (e.g. at 60 and 90 days in freezer)
        if item.location == .freezer {
            if let freezer60 = calendar.date(byAdding: .day, value: 60, to: item.purchaseDate), freezer60 > Date() {
                scheduleNotification(
                    id: "\(item.id.uuidString)-freezer60",
                    title: "Freezer Check: \(item.name)",
                    body: "It's been in there for a minute! Your \(item.name) has been in the freezer for 60 days. Tap for FDA quality guidelines.",
                    date: freezer60
                )
            }
            if let freezer90 = calendar.date(byAdding: .day, value: 90, to: item.purchaseDate), freezer90 > Date() {
                scheduleNotification(
                    id: "\(item.id.uuidString)-freezer90",
                    title: "Freezer Alert: \(item.name)",
                    body: "Your food (\(item.name)) has been in the freezer for 90 days. Check packaging for freezer burn and review FDA facts.",
                    date: freezer90
                )
            }
        }
        
        // Special Spice Rack Push Notification (at 180 days / 6 months)
        if item.location == .spiceRack {
            if let spiceReminder = calendar.date(byAdding: .day, value: 180, to: item.purchaseDate), spiceReminder > Date() {
                scheduleNotification(
                    id: "\(item.id.uuidString)-spiceRack",
                    title: "Spice Freshness: \(item.name)",
                    body: "Your spices might be hardening or losing potency! Tap to view FDA storage tips and anti-clumping guidelines.",
                    date: spiceReminder
                )
            }
        }
    }
    
    /// Cancels all scheduled notifications for a specific item
    public func cancelNotifications(for itemID: UUID) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            "\(itemID.uuidString)-10days",
            "\(itemID.uuidString)-2days",
            "\(itemID.uuidString)-1day",
            "\(itemID.uuidString)-today",
            "\(itemID.uuidString)-freezer60",
            "\(itemID.uuidString)-freezer90",
            "\(itemID.uuidString)-spiceRack"
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
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
