import Combine
import Foundation

// Analysis Model
struct AnalysisRecord: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let prediction: String // Modelin tahmini
    let advice: String
    
    // Analysis Data
    let age: Int
    let gender: String
    let coffee: Double
    let sleepHours: Double
    
    // Guest analysis check
    var isGuest: Bool = false
    
    // Actual status (Optional)
    var userRating: String?
}

class HistoryManager: ObservableObject {
    @Published var history: [AnalysisRecord] = []
    
    init() {
        loadHistory()
    }
    
    // Add record
    func addRecord(_ record: AnalysisRecord) {
        history.insert(record, at: 0)
        saveHistory()
    }
    
    // Update feedback
    func updateRating(id: UUID, rating: String) {
        if let index = history.firstIndex(where: { $0.id == id }) {
            history[index].userRating = rating
            saveHistory()
            
            // Send to backend
            sendFeedbackToBackend(record: history[index], rating: rating)
        }
    }
    
    // Remove record
    func removeRecord(id: UUID) {
        history.removeAll { $0.id == id }
        saveHistory()
    }
    
    // File Storage
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
    
    // Backend Feedback
    private func sendFeedbackToBackend(record: AnalysisRecord, rating: String) {
        // Update URL
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

