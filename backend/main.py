import os
from pathlib import Path
from typing import Any

import google.generativeai as genai
import joblib
import pandas as pd
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

# Settings
load_dotenv()
GENAI_API_KEY = os.getenv("GEMINI_API_KEY")
BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR / "models"
# Feedback dosyası yolu
FEEDBACK_FILE = BASE_DIR / "data" / "feedback_data.csv"

if GENAI_API_KEY:
    genai.configure(api_key=GENAI_API_KEY)
    # 2026 itibarıyla güncel model ismini kullandığından emin ol
    gemini_model = genai.GenerativeModel("gemini-2.5-flash-lite") 
else:
    gemini_model = None
    print("UYARI: API Key bulunamadı!")

app = FastAPI(title="Caffeine Sleep Coach API")

# Load Models
def load_model_artifacts() -> tuple[Any, Any]:
    try:
        pipeline_path = MODEL_DIR / "model_pipeline.pkl"
        le_target_path = MODEL_DIR / "le_target.pkl"

        pipeline_local = joblib.load(pipeline_path)
        le_target_local = joblib.load(le_target_path)
        
        print("Modeller başarıyla yüklendi.")
        return pipeline_local, le_target_local
    except Exception as exc:
        print(f"Model yükleme hatası: {exc}")
        return None, None

pipeline, le_target = load_model_artifacts()

# Data Models
class UserData(BaseModel):
    age: int = Field(ge=0, le=120)
    gender: str
    coffee_intake: float = Field(ge=0)
    bmi: float = Field(ge=0)
    stress_level: str
    activity_hours: float = Field(ge=0)
    smoking: int = Field(ge=0, le=1)
    alcohol: int = Field(ge=0, le=1)
    sleep_hours: float = Field(ge=0, le=24)

# API Endpoints
@app.post("/predict_and_advise")
def predict_and_advise(data: UserData):
    if pipeline is None or le_target is None:
        raise HTTPException(status_code=500, detail="Model sunucuda yüklü değil.")

    try:
        # 1. Data Preparation
        input_data = pd.DataFrame(
            [[
                data.age,
                data.gender,
                data.coffee_intake,
                data.bmi,
                data.stress_level,
                data.activity_hours,
                data.smoking,
                data.alcohol,
            ]],
            columns=[
                "Age",
                "Gender",
                "Coffee_Intake",
                "BMI",
                "Stress_Level",
                "Physical_Activity_Hours",
                "Smoking",
                "Alcohol_Consumption",
            ],
        )

        # 2. ML Prediction
        prediction_idx = pipeline.predict(input_data)[0]
        prediction_label = le_target.inverse_transform([prediction_idx])[0]

    except Exception as e:
        print(f"Tahmin Hatası: {e}")
        raise HTTPException(status_code=400, detail=f"Tahmin hatası: {str(e)}")

    # 3. Gemini Advice
    advice_text = "Tavsiye oluşturulamadı."
    if gemini_model:
        try:
            prompt = f"""
            Rol: Sertifikalı Uyku Koçu.
            Kullanıcı Bilgileri:
            - Kahve Tüketimi: {data.coffee_intake} bardak
            - Hedeflenen Uyku Süresi: {data.sleep_hours} saat
            - Stres Seviyesi: {data.stress_level}
            - Tahmin Edilen Kalite: {prediction_label} (Model Sonucu)
            
            Görev: Kullanıcıya kısa, samimi ve vurucu bir tavsiye ver. 
            Eğer uyku süresi azsa (7 saatten az) mutlaka uyar.
            Eğer kahve çoksa (2.5 bardaktan fazla) uyar.
            Cevap 3 cümleyi geçmesin. Türkçe olsun.
            """
            response = gemini_model.generate_content(prompt)
            advice_text = response.text.strip()
        except Exception as e:
            advice_text = f"Yapay zeka meşgul: {str(e)}"

    return {
        "sleep_quality": prediction_label,
        "advice": advice_text
    }

class FeedbackData(BaseModel):
    age: int
    gender: str
    coffee: float
    sleep_hours: float
    model_prediction: str 
    user_actual: str      

@app.post("/submit_feedback")
def submit_feedback(data: FeedbackData):
    new_row = {
        "Age": data.age,
        "Gender": data.gender,
        "Coffee_Intake": data.coffee,
        "Sleep_Hours": data.sleep_hours,
        "Model_Prediction": data.model_prediction,
        "Actual_Quality": data.user_actual
    }
    
    try:
        # data klasörünün varlığından emin ol
        FEEDBACK_FILE.parent.mkdir(parents=True, exist_ok=True)
        
        df = pd.DataFrame([new_row])
        if not FEEDBACK_FILE.exists():
            df.to_csv(FEEDBACK_FILE, index=False)
        else:
            df.to_csv(FEEDBACK_FILE, mode='a', header=False, index=False)
            
        return {"status": "success", "message": "Geri bildirim kaydedildi."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))