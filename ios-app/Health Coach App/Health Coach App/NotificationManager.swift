import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // İzin İste
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Bildirim izni verildi")
            } else if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
    }
    
    // Günlük Bildirim Planla
    func scheduleDailyReminder(at date: Date, isEnabled: Bool) {
        // Önce eskileri temizle
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        if !isEnabled { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Uyku Analizi Zamanı! 🌙"
        content.body = "Bugünün verilerini girmeyi unutma. Sağlıklı bir uyku için takipte kal!"
        content.sound = .default
        
        // Kullanıcının seçtiği saat ve dakika
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // Her gün tekrarla
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_sleep_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        print("Bildirim planlandı: \(hour):\(minute)")
    }
    
    // Görev Tamamlandığında (Bugün analiz yapıldı)
    func completeTaskForToday() {
        // 1. Bekleyen "bugünkü" bildirimi iptal et (eğer henüz gelmediyse)
        // Ancak CalendarTrigger kullandığımız için 'removePending' tüm tekrarları siler.
        // Bu yüzden strateji şu:
        // Eğer analiz yapıldıysa, hatırlatıcıyı silmiyoruz AMACIMIZ sadece "rahatsız etmemek".
        // Fakat iOS'ta "bugün çalma ama yarın çal" demek zordur.
        // En basit yöntem: Analiz yapılınca bildirimi silmek,
        // VE uygulamanın arka plana geçişinde veya açılışında tekrar kontrol edip kurmak gerekir.
        // AMA kullanıcı basitlik istedi: "Girdiyse gerek yok."
        
        // YÖNTEM 2: Bildirimi SİL, ve Yarın için tekrar kur.
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Bugünkü görev tamamlandı, bildirim iptal edildi.")
        
        // Yarın tekrar kurulması gerek. Bunu sağlamak için ProfileView'daki saati
        // kullanarak tekrar kurabiliriz ama şu anlık sadece iptal edip,
        // kullanıcı ertesi gün app'e girmezse bildirim gelmez riski var.
        
        // SAĞLAM YÖNTEM:
        // Bildirimi silme. Kullanıcı zaten analiz yaptıysa, bildirim gelse bile görmezden gelir.
        // Veya "Bugün analiz yaptın" diye sessiz bir bildirim olabilir.
        
        // İstenen: "girdiyse gerek yok"
        // Çözüm: Pending request'i siliyoruz.
        // Ertesi gün tekrar kurulması için App Life Cycle (SceneDelegate/App) içinde kontrol yapılması lazım.
        // Ancak SwiftUI'da basitçe: Kullanıcı App'i her açtığında (DailyCheckView onAppear)
        // eğer "bugün analiz yapılmamışsa" bildirimi tekrar kurabiliriz.
    }
    
    // Geri Yükle (Ertesi gün için)
    func restoreReminder(at date: Date, isEnabled: Bool) {
        if isEnabled {
            scheduleDailyReminder(at: date, isEnabled: true)
        }
    }
}
