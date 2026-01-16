import SwiftUI

struct ContentView: View {
    // Paylaşılan Geçmiş Yöneticisi
    @StateObject var historyManager = HistoryManager()
    
    var body: some View {
        TabView {
            // 1. Sekme: Günlük (DailyCheckView'i aşağıda tanımlayacağız veya ayrı dosya yapabilirsin, şimdilik buraya ekliyorum)
            DailyCheckView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Bugün")
                }
            
            // 2. Sekme: Profil
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profil")
                }
            
            // 3. Sekme: Misafir
            GuestView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Misafir")
                }
            
            // 4. Sekme: Geçmiş
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Geçmiş")
                }
        }
        .accentColor(.purple)
        .environmentObject(historyManager) // Tüm alt view'lara erişim
    }
}

// GÜNLÜK KONTROL SAYFASI (Home Screen) 
struct DailyCheckView: View {
    // Paylaşılan Geçmiş Yöneticisi
    @EnvironmentObject var historyManager: HistoryManager
    
    // Profil Verilerini Otomatik Çek
    @AppStorage("userAge") private var age: Double = 22
    @AppStorage("userGender") private var gender = "Male"
    @AppStorage("userBMI") private var bmi: Double = 24.0
    @AppStorage("userStress") private var stress = "Medium"
    @AppStorage("userSmoking") private var isSmoking = false
    @AppStorage("userAlcohol") private var isAlcoholic = false
    
    @State private var coffee: Double = 2
    @State private var sleep: Double = 7
    @State private var activity: Double = 1
    
    @State private var showResult = false
    @State private var resultData: APIResponse?
    @State private var isLoading = false
    
    // 🌑 Dark Mode için Dinamik Renk Tanımı
    // Bu renk Gündüz Beyaz, Gece Koyu Gri olur.
    let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Arka plan rengi (Gündüz açık gri, Gece tam siyah)
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Bilgi Kartı
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Hoş geldin!")
                                    .font(.caption)
                                    .foregroundColor(.secondary) // Otomatik gri tonu
                                Text("Profilin: \(Int(age)) Yaş, BMI \(String(format: "%.1f", bmi))")
                                    .font(.headline)
                                    .foregroundColor(.primary) // Gündüz Siyah, Gece Beyaz
                            }
                            Spacer()
                        }
                        .padding()
                        .background(cardBackground) //
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1) // Hafif gölge
                        
                        // Hızlı Girdiler
                        VStack(spacing: 15) {
                                                    Text("Bugünkü Verilerin")
                                                        .font(.title2)
                                                        .bold()
                                                        .foregroundColor(.primary)
                                                    
                                                    // 1. KAHVE KARTI (Animasyonlu)
                                                    HStack {
                                                        Image(systemName: getCoffeeIcon(coffee))
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 30)
                                                            .foregroundColor(.brown)
                                                            // Animasyon Ekliyoruz: Değer değişince ikon zıplasın
                                                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: coffee)
                                                        
                                                        Text("Kahve: \(String(format: "%.1f", coffee))")
                                                            .foregroundColor(.primary)
                                                        Spacer()
                                                        Stepper("", value: $coffee, in: 0...10, step: 0.5).labelsHidden()
                                                    }
                                                    .padding()
                                                    .background(cardBackground)
                                                    .cornerRadius(10)
                                                    
                                                    // 2. UYKU KARTI
                                                    HStack {
                                                        Image(systemName: "moon.stars.fill")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 30)
                                                            .foregroundColor(.purple)
                                                        
                                                        Text("Hedef Uyku: \(String(format: "%.1f", sleep))")
                                                            .foregroundColor(.primary)
                                                        Spacer()
                                                        Slider(value: $sleep, in: 4...12, step: 0.5).frame(width: 120)
                                                    }
                                                    .padding()
                                                    .background(cardBackground)
                                                    .cornerRadius(10)
                                                    
                                                    // 3. AKTİVİTE KARTI (Animasyonlu & Renk Değişen)
                                                    HStack {
                                                        Image(systemName: getActivityIcon(activity))
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 30)
                                                            // Az spor: Yeşil, Çok spor: Kırmızı/Turuncu
                                                            .foregroundColor(activity > 4.5 ? .red : .green)
                                                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: activity)
                                                        
                                                        Text("Aktivite: \(String(format: "%.1f", activity))")
                                                            .foregroundColor(.primary)
                                                        Spacer()
                                                        Stepper("", value: $activity, in: 0...10, step: 0.5).labelsHidden()
                                                    }
                                                    .padding()
                                                    .background(cardBackground)
                                                    .cornerRadius(10)
                                                }
                                                .padding(.horizontal)
                        
                        Button(action: analyzeDaily) {
                            HStack {
                                if isLoading { ProgressView().tint(.white) }
                                else { Text("GÜNLÜK ANALİZ YAP").bold() }
                            }
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.purple).foregroundColor(.white).cornerRadius(15)
                        }
                        .padding()
                        .disabled(isLoading)
                    }
                }
                .navigationTitle("Ana Sayfa 🏠")
            }
            .sheet(isPresented: $showResult) {
                if let res = resultData {
                    ResultView(quality: res.sleep_quality, advice: res.advice)
                }
            }
        }
    }
    
    func analyzeDaily() {
        isLoading = true
        APIService.performAnalysis(
            age: age, gender: gender, coffee: coffee, bmi: bmi,
            stress: stress, activity: activity, smoke: isSmoking, alcohol: isAlcoholic, sleep: sleep
        ) { result in
            isLoading = false
            switch result {
            case .success(let response):
                self.resultData = response
                self.showResult = true
                
                // Geçmişe Kaydet
                let record = AnalysisRecord(
                    date: Date(),
                    prediction: response.sleep_quality,
                    advice: response.advice,
                    age: Int(age),
                    gender: gender,
                    coffee: coffee,
                    sleepHours: sleep
                )
                historyManager.addRecord(record)
                
                // Görev Tamamlandı: Bildirimi İptal Et
                NotificationManager.shared.completeTaskForToday()
                
            case .failure(let error):
                print("Hata: \(error.localizedDescription)")
            }
        }
    }
}
