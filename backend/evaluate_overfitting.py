import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import pathlib
import joblib

# Paths
BASE_DIR = pathlib.Path(__file__).resolve().parent
DATA_PATH = BASE_DIR / "data" / "synthetic_coffee_health_10000.csv"
MODEL_DIR = BASE_DIR / "models"

# Load Data
df = pd.read_csv(DATA_PATH)

# Target Encoding
le_target = joblib.load(MODEL_DIR / "le_target.pkl")
df['Sleep_Quality'] = le_target.transform(df['Sleep_Quality'])

# Note: Sleep_Hours is excluded from training features
features = [
    "Age", "Gender", "Coffee_Intake", "BMI",
    "Stress_Level", "Physical_Activity_Hours",
    "Smoking", "Alcohol_Consumption",
]

X = df[features]
y = df['Sleep_Quality']

# Train-Test Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Load Model Pipeline
pipeline = joblib.load(MODEL_DIR / "model_pipeline.pkl")
print("Model pipeline loaded.")

# Evaluation using the pipeline

train_preds = pipeline.predict(X_train)
test_preds = pipeline.predict(X_test)

train_acc = accuracy_score(y_train, train_preds)
test_acc = accuracy_score(y_test, test_preds)

print(f"Training Accuracy: {train_acc:.4f}")
print(f"Test Accuracy: {test_acc:.4f}")
print("-" * 30)
print("Classification Report (Test):")
print(classification_report(y_test, test_preds, target_names=le_target.classes_))
print("-" * 30)
print("Confusion Matrix (Test):")
print(confusion_matrix(y_test, test_preds))
