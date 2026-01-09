import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // Request Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Bildirim izni verildi")
            } else if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
    }
    
    // Schedule Daily Reminder
    func scheduleDailyReminder(at date: Date, isEnabled: Bool) {
        // Clear old notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        if !isEnabled { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Uyku Analizi Zamanı! 🌙"
        content.body = "Bugünün verilerini girmeyi unutma. Sağlıklı bir uyku için takipte kal!"
        content.sound = .default
        
        // User selected time
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // Repeat daily
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_sleep_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        print("Bildirim planlandı: \(hour):\(minute)")
    }
    
    // Task Completed
    func completeTaskForToday() {
        // Clear pending request.
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Bugünkü görev tamamlandı, bildirim iptal edildi.")
    }
    
    // Restore Reminder
    func restoreReminder(at date: Date, isEnabled: Bool) {
        if isEnabled {
            scheduleDailyReminder(at: date, isEnabled: true)
        }
    }
}
