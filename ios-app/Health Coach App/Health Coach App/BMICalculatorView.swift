import SwiftUI

struct BMICalculatorView: View {
    // @Binding: Bu sayfa veriyi kendisi tutmaz, çağıran sayfadan ödünç alır ve değiştirir.
    @Binding var weight: Double
    @Binding var height: Double
    @Binding var bmiResult: Double
    
    // Sadece bu sayfa içinde hesaplama için
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("Vücut Ölçüleri")) {
                HStack {
                    Text("Boy (cm)")
                    Spacer()
                    Text("\(Int(height))")
                }
                Slider(value: $height, in: 140...220, step: 1)
                
                HStack {
                    Text("Kilo (kg)")
                    Spacer()
                    Text("\(Int(weight))")
                }
                Slider(value: $weight, in: 40...150, step: 1)
            }
            
            Section(header: Text("Sonuç")) {
                HStack {
                    Text("BMI Değerin:")
                    Spacer()
                    Text(String(format: "%.1f", calculateBMI()))
                        .font(.title2)
                        .bold()
                        .foregroundColor(getBMIColor())
                }
                
                Button(action: {
                    // Kaydet ve Çık
                    bmiResult = calculateBMI()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Hesapla ve Kaydet")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("BMI Hesaplayıcı")
    }
    
    func calculateBMI() -> Double {
        let h_meter = height / 100.0
        return weight / (h_meter * h_meter)
    }
    
    func getBMIColor() -> Color {
        let b = calculateBMI()
        if b < 18.5 { return .blue }
        else if b < 25 { return .green }
        else if b < 30 { return .orange }
        else { return .red }
    }
}
