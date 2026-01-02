from pathlib import Path

import joblib
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, OrdinalEncoder, LabelEncoder
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score

BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR / "data" / "synthetic_coffee_health_10000.csv"
MODEL_DIR = BASE_DIR / "models"

# 1. Veri Yükleme
df = pd.read_csv(DATA_PATH)

# Hedef Değişken (Uyku Kalitesi) - LabelEncoder kullanmaya devam ediyoruz çünkü bu y (hedef)
le_target = LabelEncoder()
df['Sleep_Quality'] = le_target.fit_transform(df['Sleep_Quality'])

# 2. Pipeline Tanımlama
# Sayısal ve Kategorik Değişkenleri Ayır
numeric_features = ["Age", "Coffee_Intake", "BMI", "Physical_Activity_Hours", "Smoking", "Alcohol_Consumption"]
categorical_features = ["Gender"]
ordinal_features = ["Stress_Level"]

# Stress Level için sıralama
stress_order = [['Low', 'Medium', 'High']]

preprocessor = ColumnTransformer(
    transformers=[
        ('num', 'passthrough', numeric_features),
        ('cat', OneHotEncoder(handle_unknown='ignore'), categorical_features),
        ('ord', OrdinalEncoder(categories=stress_order, handle_unknown='use_encoded_value', unknown_value=-1), ordinal_features)
    ]
)

# RandomForest Modeli
rf = RandomForestClassifier(random_state=42, class_weight='balanced')

# Pipeline Oluşturma
pipeline = Pipeline(steps=[
    ('preprocessor', preprocessor),
    ('classifier', rf)
])

# 3. Model Eğitimi için Veri Hazırlığı
# Pipeline kullandığımız için burada manuel encoding yapmıyoruz!
X = df.drop(columns=['Sleep_Quality', 'Sleep_Hours']) # Sleep_Hours eğitimde kullanılmıyor
y = df['Sleep_Quality']

# Veri setindeki sınıf dağılımını kontrol et
print("Sınıf Dağılımı (Orijinal):")
print(y.value_counts())

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# 4. Grid Search
param_grid = {
    'classifier__n_estimators': [50, 100, 200],
    'classifier__max_depth': [None, 10, 20],
    'classifier__min_samples_split': [2, 5, 10],
    'classifier__min_samples_leaf': [1, 2, 4]
}

# GridSearchCV
grid_search = GridSearchCV(estimator=pipeline, param_grid=param_grid, 
                           cv=3, n_jobs=-1, verbose=2, scoring='accuracy')

print("Model eğitimi ve hiperparametre araması başlıyor...")
grid_search.fit(X_train, y_train)

best_pipeline = grid_search.best_estimator_
print(f"En iyi parametreler: {grid_search.best_params_}")

# 5. Değerlendirme
# Pipeline predict metodunda preprocessing'i otomatik yapar
train_preds = best_pipeline.predict(X_train)
test_preds = best_pipeline.predict(X_test)

print("-" * 30)
print(f"Eğitim Doğruluğu: {accuracy_score(y_train, train_preds):.4f}")
print(f"Test Doğruluğu: {accuracy_score(y_test, test_preds):.4f}")
print("-" * 30)
print("Sınıflandırma Raporu (Test):")
print(classification_report(y_test, test_preds, target_names=le_target.classes_))
print("-" * 30)
print("Konfüzyon Matrisi (Test):")
print(confusion_matrix(y_test, test_preds))

# 6. Kaydetme
MODEL_DIR.mkdir(parents=True, exist_ok=True)
# Tüm pipeline'ı kaydediyoruz
joblib.dump(best_pipeline, MODEL_DIR / "model_pipeline.pkl")
# Target encoder'ı ayrıca kaydediyoruz (inverse transform için gerekli)
joblib.dump(le_target, MODEL_DIR / "le_target.pkl")

# Eski dosyaları temizleyelim (opsiyonel ama kafa karışıklığını önler)
for f in ["uyku_modeli.pkl", "le_gender.pkl", "le_stress.pkl"]:
    if (MODEL_DIR / f).exists():
        (MODEL_DIR / f).unlink()
        print(f"Eski dosya silindi: {f}")
