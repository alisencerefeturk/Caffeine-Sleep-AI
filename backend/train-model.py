# train_model.py
import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder

df = pd.read_csv('data/synthetic_coffee_health_10000.csv')

# 2. Veri Ön İşleme (Sayısal olmayanları sayısala çevirme)
le_gender = LabelEncoder()
df['Gender'] = le_gender.fit_transform(df['Gender'])

# Stres: Low=0, Medium=1, High=2
le_stress = LabelEncoder()
df['Stress_Level'] = le_stress.fit_transform(df['Stress_Level'])

# Hedef Değişken (Uyku Kalitesi)
le_target = LabelEncoder()
df['Sleep_Quality'] = le_target.fit_transform(df['Sleep_Quality'])

# 3. Model Eğitimi için Özellikleri (Girdiler)
features = ['Age', 'Gender', 'Coffee_Intake', 'BMI', 'Stress_Level', 
            'Physical_Activity_Hours', 'Smoking', 'Alcohol_Consumption']

X = df[features]
y = df['Sleep_Quality']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

print(f"Model Doğruluğu: {model.score(X_test, y_test):.2f}")

joblib.dump(model, 'models/uyku_modeli.pkl')
joblib.dump(le_gender, 'models/le_gender.pkl')
joblib.dump(le_stress, 'models/le_stress.pkl')
joblib.dump(le_target, 'models/le_target.pkl')