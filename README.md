# Caffeine AI: Akıllı Uyku ve Sağlık Koçu ☕
Caffeine AI, kullanıcıların günlük kafein tüketimi, fiziksel aktivite ve kişisel profil verilerini analiz ederek uyku kalitesini tahmin eden ve yapay zeka destekli kişiselleştirilmiş tavsiyeler sunan kapsamlı bir sağlık uygulamasıdır.

## Öne Çıkan Özellikler 🌟 
Kişiselleştirilmiş Profil: Yaş, BMI, cinsiyet ve alışkanlıkların (sigara/alkol) kaydedildiği kalıcı kullanıcı profili.

Akıllı BMI Hesaplayıcı: Boy ve kilo verilerine göre anlık BMI hesaplama ve kategorilendirme.

Günlük Takip: Kafein alımı, hedeflenen uyku süresi ve aktivite düzeyinin animasyonlu ikonlarla takibi.

Makine Öğrenmesi (ML) Tahmini: Random Forest algoritması ile uyku kalitesinin (Poor, Fair, Good) tahmini.

AI Koçluk: Google Gemini API entegrasyonu ile analiz sonuçlarına göre 2 cümlelik vurucu ve bilimsel tavsiyeler.

Geri Bildirim Döngüsü (Feedback Loop): Kullanıcının model tahminini değerlendirmesi ve bu verinin modelin iyileştirilmesi için backend'de (CSV) toplanması.

Geçmiş Takibi: Yapılan tüm analizlerin tarih bazlı saklanması.

Akıllı Bildirimler: Analiz yapılmayan günlerde akşam 21:00'de hatırlatma gönderen, analiz yapıldığında ise kendini susturan sistem.

 ## Teknoloji Yığını (Tech Stack) 🏗️
**Frontend (iOS App)<br/>
Dil: Swift (SwiftUI)<br/>
Mimari: MVVM (Model-View-ViewModel) mantığına uygun modüler yapı.<br/>
Veri Saklama: @AppStorage (User Defaults) ve JSON tabanlı yerel arşivleme.<br/>
Bildirimler: UserNotifications framework.<br/>
Backend (API)<br/>
Framework: FastAPI (Python)<br/>
Deployment: Google Cloud Run (Dockerized)<br/>
CI/CD: Google Cloud Build (cloudbuild.yaml)<br/>
AI: Google Gemini 1.5 Flash (Generative AI)<br/>
ML: Scikit-Learn (Random Forest Classifier)**

## Kurulum ve Çalıştırma 🚀
**cd backend<br/>
pip install -r requirements.txt<br/>
uvicorn main:app --reload**

2. Google Cloud Deployment

Proje, GitHub üzerinden otomatik olarak Google Cloud Run'a bağlanacak şekilde konfigüre edilmiştir. cloudbuild.yaml dosyası sayesinde her push işleminde sistem kendini günceller.

3. iOS Uygulamasını Çalıştırma

Xcode ile projeyi açın.

ProjectHelpers.swift içindeki urlString değişkenini kendi Google Cloud URL'niz ile güncelleyin.

Info.plist dosyasında App Transport Security Settings altında Allow Arbitrary Loads seçeneğinin YES olduğunu kontrol edin.

Simulator veya gerçek cihazda çalıştırın.

 ## Makine Öğrenmesi Modeli 📈
Uygulama, 10.000 satırlık sentetik sağlık verisi üzerinde eğitilmiş bir Random Forest Classifier kullanır. Model; yaş, cinsiyet, kafein miktarı, BMI, stres seviyesi ve aktivite saatlerini ağırlıklandırarak yüksek doğrulukla uyku kalitesi tahmini yapar.
