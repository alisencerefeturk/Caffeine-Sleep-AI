import SwiftUI

// --- 1. VERİ MODELLERİ ---
struct APIResponse: Codable {
    let sleep_quality: String
    let advice: String
}

// --- 2. API SERVİSİ (Static Fonksiyon) ---
class APIService {
    static func performAnalysis(
        age: Double, gender: String, coffee: Double, bmi: Double,
        stress: String, activity: Double, smoke: Bool, alcohol: Bool, sleep: Double,
        completion: @escaping (Result<APIResponse, Error>) -> Void
    ) {
        // --- URL'Yİ BURAYA GİR (Ngrok veya Localhost) ---
        guard let url = URL(string: "https://caffeine-sleep-ai-1073956464936.europe-west1.run.app/predict_and_advise") else { return }
        
        let requestData: [String: Any] = [
            "age": Int(age), "gender": gender, "coffee_intake": coffee, "bmi": bmi,
            "stress_level": stress, "activity_hours": activity,
            "smoking": smoke ? 1 : 0, "alcohol": alcohol ? 1 : 0, "sleep_hours": sleep
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else { return }
                
                do {
                    let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// --- 3. ORTAK TASARIM ELEMANLARI ---

// Çeviri Yardımcısı
func getTurkishQuality(_ quality: String) -> String {
    switch quality {
    case "Poor": return "Kötü"
    case "Fair": return "Orta"
    case "Good": return "İyi"
    case "Excellent": return "Mükemmel"
    default: return quality
    }
}

// Renk Seçicisi
func getQualityColor(_ quality: String) -> Color {
    switch quality {
    case "Poor": return .red
    case "Fair": return .orange
    case "Good": return .blue
    case "Excellent": return .green
    default: return .gray
    }
}

// Sonuç Gösterme Ekranı (Her yerden çağrılabilir)
struct ResultView: View {
    let quality: String
    let advice: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Arkaplan: Sistem temasına duyarlı
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Text("Analiz Sonucu")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                    .foregroundColor(.primary)
                
                // Sonuç Kartı (Yuvarlatılmış Dikdörtgen)
                VStack {
                    Text(getTurkishQuality(quality))
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.vertical, 30) // Dikey boşluk
                        .padding(.horizontal, 50) // Yatay boşluk
                }
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(getQualityColor(quality).gradient) // Modern Gradyan
                        .shadow(radius: 10, y: 5)
                )
                
                // Tavsiye Alanı (Glassmorphism & Adaptive)
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.purple)
                            Text("Yapay Zeka Tavsiyesi")
                                .font(.headline)
                                .foregroundColor(.purple)
                        }
                        
                        Divider()
                        
                        Text(advice)
                            .font(.body)
                            .foregroundColor(.primary) // Koyu modda beyaz, açık modda siyah olur
                            .lineSpacing(4)
                            .padding(.top, 5)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.secondarySystemBackground)) // Adaptive gri/koyu
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Kapat")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding()
                .padding(.bottom)
            }
        }
    }
}

// Kahve miktarına göre ikon seçen fonksiyon
func getCoffeeIcon(_ amount: Double) -> String {
    if amount <= 1.0 {
        return "cup.and.saucer.fill" // Türk kahvesi / Espresso fincanı
    } else if amount <= 3.0 {
        return "mug.fill" // Kupa
    } else {
        return "takeoutbag.and.cup.and.straw.fill" // Kahve bağımlısı
    }
}

// Aktivite saatine göre ikon seçen fonksiyon
func getActivityIcon(_ amount: Double) -> String {
    if amount < 1.0 {
        return "figure.walk" // Yürüyüş
    } else if amount < 2.5 {
        return "figure.run" // Koşu
    } else {
        return "bolt.heart.fill" // Yüksek Efor / Kardiyo
    }
}
