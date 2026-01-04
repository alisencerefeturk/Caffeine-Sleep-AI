import SwiftUI

struct ProfileView: View {
    // Kalıcı Hafıza (User Defaults)
    @AppStorage("userAge") private var age: Double = 22
    @AppStorage("userGender") private var gender = "Male"
    @AppStorage("userHeight") private var height: Double = 170
    @AppStorage("userWeight") private var weight: Double = 70
    @AppStorage("userBMI") private var bmi: Double = 24.2
    @AppStorage("userStress") private var stress = "Medium"
    @AppStorage("userSmoking") private var isSmoking = false
    @AppStorage("userAlcohol") private var isAlcoholic = false
    
    // Bildirim Ayarları
    @AppStorage("isNotificationEnabled") private var isNotificationEnabled = true
    @AppStorage("notificationTime") private var notificationTime = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    
    var body: some View {
        NavigationView {
            Form {
                // KİŞİSEL BİLGİLER
                Section(header: Text("Genel Bilgiler")) {
                    Stepper("Yaş: \(Int(age))", value: $age, in: 10...90)
                    Picker("Cinsiyet", selection: $gender) {
                        Text("Erkek").tag("Male")
                        Text("Kadın").tag("Female")
                    }.pickerStyle(SegmentedPickerStyle())
                }
                
                // BMI KISMI (Burada köprü var)
                Section(header: Text("Vücut Kitle Endeksi")) {
                    HStack {
                        Text("Mevcut BMI:")
                        Spacer()
                        Text(String(format: "%.1f", bmi))
                            .bold()
                            .foregroundColor(.purple)
                    }
                    
                    // KÖPRÜ: Buraya basınca BMI Hesaplayıcıya gidiyor
                    NavigationLink(destination: BMICalculatorView(weight: $weight, height: $height, bmiResult: $bmi)) {
                        HStack {
                            Image(systemName: "scalemass.fill")
                            Text("BMI Hesaplayıcıyı Aç")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // ALIŞKANLIKLAR
                Section(header: Text("Genel Alışkanlıklar")) {
                    Picker("Genel Stres", selection: $stress) {
                        Text("Düşük").tag("Low")
                        Text("Orta").tag("Medium")
                        Text("Yüksek").tag("High")
                    }
                    Toggle("Sigara Kullanıyorum", isOn: $isSmoking)
                    Toggle("Alkol Tüketiyorum", isOn: $isAlcoholic)
                }
                
                // GÜNLÜK HATIRLATICI
                Section(header: Text("Bildirimler")) {
                    Toggle("Günlük Hatırlatıcı", isOn: $isNotificationEnabled)
                        .onChange(of: isNotificationEnabled) { _, newValue in
                            NotificationManager.shared.scheduleDailyReminder(at: notificationTime, isEnabled: newValue)
                        }
                    
                    if isNotificationEnabled {
                        DatePicker("Saat Seçimi", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .onChange(of: notificationTime) { _, newTime in
                                NotificationManager.shared.scheduleDailyReminder(at: newTime, isEnabled: true)
                            }
                    }
                }
            }
            .navigationTitle("Profilim 👤")
            .onAppear {
                NotificationManager.shared.requestPermission()
            }
        }
    }
}

