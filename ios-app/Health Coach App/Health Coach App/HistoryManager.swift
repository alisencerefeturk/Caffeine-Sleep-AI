import Combine
import Foundation

// Geçmişteki her bir analizin modeli
struct AnalysisRecord: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let prediction: String
    let advice: String
    
    // Analiz sırasındaki veriler (Geri bildirim için lazım)
    let age: Int
    let gender: String
    let coffee: Double
    let sleepHours: Double
    
    // Misafir mi yoksa kendi analizi mi?
    var isGuest: Bool = false
    
    // Kullanıcının sonradan gireceği gerçek durum (Opsiyonel)
    var userRating: String?
}

class HistoryManager: ObservableObject {
    @Published var history: [AnalysisRecord] = []
    
    init() {
        loadHistory()
    }
    
    // Yeni kayıt ekle
    func addRecord(_ record: AnalysisRecord) {
        history.insert(record, at: 0) // En başa ekle
        saveHistory()
    }
    
    // Geri bildirimi güncelle
    func updateRating(id: UUID, rating: String) {
        if let index = history.firstIndex(where: { $0.id == id }) {
            history[index].userRating = rating
            saveHistory()
            
            // Backend'e gönder
            sendFeedbackToBackend(record: history[index], rating: rating)
        }
    }
    
    // Kayıt sil
    func removeRecord(id: UUID) {
        history.removeAll { $0.id == id }
        saveHistory()
    }
    
    // --- Dosya Kayıt İşlemleri (JSON) ---
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "AnalysisHistory")
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "AnalysisHistory"),
           let decoded = try? JSONDecoder().decode([AnalysisRecord].self, from: data) {
            history = decoded
        }
    }
    
    // --- Backend'e Feedback Gönderme ---
    private func sendFeedbackToBackend(record: AnalysisRecord, rating: String) {
        // URL'Yİ GÜNCELLEMEYİ UNUTMA
        guard let url = URL(string: "https://biotic-zelda-dobsonfly.ngrok-free.dev/submit_feedback") else { return }
        
        let body: [String: Any] = [
            "age": record.age,
            "gender": record.gender,
            "coffee": record.coffee,
            "sleep_hours": record.sleepHours,
            "model_prediction": record.prediction,
            "user_actual": rating
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request).resume()
    }
}

