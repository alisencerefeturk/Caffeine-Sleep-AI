import SwiftUI
import Charts

struct HistoryView: View {
    @EnvironmentObject var historyManager: HistoryManager
    @State private var selectedRecord: AnalysisRecord?
    
    var body: some View {
        NavigationView {
            List {
                if historyManager.history.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "clock.badge.questionmark")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .foregroundColor(.gray)
                        Text("Henüz bir analiz yapılmadı.")
                            .foregroundColor(.gray)
                        Text("Ana sayfadan analiz yaparak geçmişi oluştur.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                }
                
                ForEach(historyManager.history) { record in
                    Button(action: { selectedRecord = record }) {
                        VStack(alignment: .leading, spacing: 10) {
                            // Tarih ve Tahmin
                            HStack {
                                Text(record.date, style: .date)
                                    .font(.caption).foregroundColor(.gray)
                                
                                // Misafir Etiketi
                                if record.isGuest {
                                    Text("Misafir")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.purple.opacity(0.2))
                                        .foregroundColor(.purple)
                                        .cornerRadius(4)
                                }
                                
                                Spacer()
                                Text(getTurkishQuality(record.prediction))
                                    .font(.headline)
                                    .foregroundColor(getQualityColor(record.prediction))
                            }
                            
                            // Detay
                            Text("Hedef Uyku: \(String(format: "%.1f", record.sleepHours)) sa | Kahve: \(String(format: "%.1f", record.coffee))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            // Geri Bildirim Kısmı
                            if let rating = record.userRating {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                    Text("Gerçekleşen: \(getTurkishQuality(rating))")
                                        .font(.caption).bold()
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Aslında nasıl uyudun?")
                                        .font(.caption).foregroundColor(.orange)
                                    HStack(spacing: 10) {
                                        FeedbackButton(title: "Kötü", apiValue: "Poor", color: .red, record: record)
                                        FeedbackButton(title: "Orta", apiValue: "Fair", color: .orange, record: record)
                                        FeedbackButton(title: "İyi", apiValue: "Good", color: .blue, record: record)
                                        FeedbackButton(title: "Mükemmel", apiValue: "Excellent", color: .green, record: record)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .onDelete(perform: deleteRecords)
            }
            .navigationTitle("Geçmiş & Geri Bildirim")
            .toolbar {
                EditButton()
            }
            .sheet(item: $selectedRecord) { record in
                RecordDetailView(record: record)
            }
        }
    }
    
    func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            let record = historyManager.history[index]
            historyManager.removeRecord(id: record.id)
        }
    }
}

// DETAY GÖRÜNÜMÜ
struct RecordDetailView: View {
    let record: AnalysisRecord
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Analiz Bilgileri")) {
                    LabeledRow(label: "Tarih", value: record.date.formatted(date: .long, time: .shortened))
                    LabeledRow(label: "Analiz Türü", value: record.isGuest ? "Misafir" : "Kişisel")
                    LabeledRow(label: "Model Tahmini", value: getTurkishQuality(record.prediction))
                    if let rating = record.userRating {
                        LabeledRow(label: "Gerçekleşen", value: getTurkishQuality(rating))
                    }
                }
                
                Section(header: Text("Kullanıcı Verileri")) {
                    LabeledRow(label: "Yaş", value: "\(record.age)")
                    LabeledRow(label: "Cinsiyet", value: record.gender == "Male" ? "Erkek" : "Kadın")
                    LabeledRow(label: "Kahve Tüketimi", value: "\(String(format: "%.1f", record.coffee)) bardak")
                    LabeledRow(label: "Hedef Uyku", value: "\(String(format: "%.1f", record.sleepHours)) saat")
                }
                
                Section(header: Text("Yapay Zeka Tavsiyesi")) {
                    Text(record.advice)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            .navigationTitle("Detay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}

struct LabeledRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

// Yardımcı Buton (Türkçe görünüm, API'ye İngilizce gönder)
struct FeedbackButton: View {
    let title: String    // Görünen metin (Türkçe)
    let apiValue: String // API'ye gönderilen değer (İngilizce)
    let color: Color
    let record: AnalysisRecord
    @EnvironmentObject var historyManager: HistoryManager
    
    var body: some View {
        Button(action: {
            historyManager.updateRating(id: record.id, rating: apiValue)
        }) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
