import SwiftUI

struct GuestView: View {
    // Paylaşılan Geçmiş Yöneticisi
    @EnvironmentObject var historyManager: HistoryManager
    
    // Geçici Değişkenler (@State)
    @State private var gAge: Double = 25
    @State private var gGender = "Female"
    @State private var gHeight: Double = 165 // Misafir boyu
    @State private var gWeight: Double = 60  // Misafir kilosu
    @State private var gBMI: Double = 22     // Misafir BMI
    
    @State private var gCoffee: Double = 3
    @State private var gSleep: Double = 7
    @State private var gActivity: Double = 2
    @State private var gStress = "Medium"
    @State private var gSmoke = false
    @State private var gAlcohol = false
    
    // Sonuç Ekranı Kontrolü
    @State private var showResult = false
    @State private var resultData: APIResponse?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Arkadaşının Bilgileri")) {
                    Stepper("Yaş: \(Int(gAge))", value: $gAge, in: 18...80)
                    Picker("Cinsiyet", selection: $gGender) {
                        Text("Erkek").tag("Male")
                        Text("Kadın").tag("Female")
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    // BMI KÖPRÜSÜ (MİSAFİR İÇİN)
                    HStack {
                        Text("BMI: \(String(format: "%.1f", gBMI))")
                        Spacer()
                        NavigationLink(destination: BMICalculatorView(weight: $gWeight, height: $gHeight, bmiResult: $gBMI)) {
                            Text("Hesapla")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Alışkanlıklar")) {
                    Stepper("Kahve: \(gCoffee, specifier: "%.1f")", value: $gCoffee, in: 0...10, step: 0.5)
                    Stepper("Uyku: \(gSleep, specifier: "%.1f")", value: $gSleep, in: 4...12, step: 0.5)
                    Stepper("Aktivite: \(gActivity, specifier: "%.1f")", value: $gActivity, in: 0...10, step: 0.5)
                    
                    Picker("Stres", selection: $gStress) {
                        Text("Düşük").tag("Low")
                        Text("Orta").tag("Medium")
                        Text("Yüksek").tag("High")
                    }
                }
                
                Button(action: analyzeGuest) {
                    HStack {
                        if isLoading { ProgressView() }
                        else { Text("Arkadaşım İçin Analiz Et") }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(isLoading)
            }
            .navigationTitle("Misafir Modu")
            .sheet(isPresented: $showResult) {
                if let res = resultData {
                    ResultView(quality: res.sleep_quality, advice: res.advice)
                }
            }
        }
    }
    
    func analyzeGuest() {
        isLoading = true
        APIService.performAnalysis(
            age: gAge, gender: gGender, coffee: gCoffee, bmi: gBMI,
            stress: gStress, activity: gActivity, smoke: gSmoke, alcohol: gAlcohol, sleep: gSleep
        ) { result in
            isLoading = false
            switch result {
            case .success(let response):
                self.resultData = response
                self.showResult = true
                
                // Geçmişe Kaydet
                var record = AnalysisRecord(
                    date: Date(),
                    prediction: response.sleep_quality,
                    advice: response.advice,
                    age: Int(gAge),
                    gender: gGender,
                    coffee: gCoffee,
                    sleepHours: gSleep
                )
                record.isGuest = true  // Misafir analizi
                historyManager.addRecord(record)
                
            case .failure(let error):
                print("Hata: \(error.localizedDescription)")
            }
        }
    }
}

