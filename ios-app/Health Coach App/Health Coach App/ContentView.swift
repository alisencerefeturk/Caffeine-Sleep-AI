import SwiftUI

// Root ContentView hosts the TabView and provides shared environment objects
struct ContentView: View {
    // Provide HistoryManager to all child views
    @StateObject private var historyManager = HistoryManager()
    
    var body: some View {
        TabView {
            // 1. Daily Tab
            DailyCheckView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Bugün")
                }
            
            // 2. Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profil")
                }
            
            // 3. Guest Tab
            GuestView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Misafir")
                }
            
            // 4. History Tab
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Geçmiş")
                }
        }
        .accentColor(.purple)
        .environmentObject(historyManager)
    }
}

// Daily Check View 
struct DailyCheckView: View {
    // Shared Manager from environment
    @EnvironmentObject var historyManager: HistoryManager
    
    // Fetch Profile Data
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
    
    // Dynamic Card Background
    let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Color
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Info Card
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Hoş geldin!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Profilin: \(Int(age)) Yaş, BMI \(String(format: "%.1f", bmi))")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(cardBackground)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        // Quick Inputs
                        Text("Bugünkü Verilerin")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                        
                        // 1. Coffee Card
                        HStack {
                            Image(systemName: getCoffeeIcon(coffee))
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .foregroundColor(.brown)
                            
                            Text("Kahve: \(String(format: "%.1f", coffee))")
                                .foregroundColor(.primary)
                            Spacer()
                            Stepper("", value: $coffee, in: 0...10, step: 0.5).labelsHidden()
                        }
                        .padding()
                        .background(cardBackground)
                        .cornerRadius(10)
                        
                        // 2. Sleep Card
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
                        
                        // 3. Activity Card
                        HStack {
                            Image(systemName: getActivityIcon(activity))
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
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
                    .padding(.horizontal)
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
    
    private func getCoffeeIcon(_ amount: Double) -> String {
        switch amount {
        case 0: return "cup.and.saucer"
        case 0..<2: return "cup.and.saucer.fill"
        case 2..<5: return "mug.fill"
        default: return "flame"
        }
    }
    
    private func getActivityIcon(_ level: Double) -> String {
        switch level {
        case 0..<2: return "figure.walk"
        case 2..<5: return "figure.run"
        case 5..<8: return "figure.strengthtraining.traditional"
        default: return "bolt.fill"
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
                
                // Save to History
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
                
                // Task Completed
                NotificationManager.shared.completeTaskForToday()
                
            case .failure(let error):
                print("Hata: \(error.localizedDescription)")
            }
        }
    }
}
