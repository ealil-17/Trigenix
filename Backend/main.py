from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import joblib
import pandas as pd
import numpy as np
import io
import os
import traceback
from pydantic import BaseModel

app = FastAPI(
    title="Arrhythmia Risk Prediction API",
    description="API to predict the risk of Arrhythmia from an ECG signal file (CSV format).",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the trained model (fixed path assuming this is in Backend/main.py)
MODEL_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "model", "arrhythmia_rf_model.pkl")

# Login Request Schema
class LoginRequest(BaseModel):
    email: str
    password: str

try:
    model = joblib.load(MODEL_PATH)
    print(f"Successfully loaded model from {MODEL_PATH}")
except Exception as e:
    print(f"Error loading model: {e}")
    model = None

@app.get("/")
def read_root():
    return {"message": "Welcome to the Arrhythmia Risk Prediction API"}

@app.post("/login/doctor")
async def login_doctor(credentials: LoginRequest):
    # TODO: Implement real database validation
    if credentials.email == "doctor@test.com" and credentials.password == "password":
        return {"message": "Login successful", "role": "doctor", "email": credentials.email}
    else:
        raise HTTPException(status_code=401, detail="Invalid doctor credentials")

@app.post("/login/patient")
async def login_patient(credentials: LoginRequest):
    # TODO: Implement real database validation
    if credentials.email == "patient@test.com" and credentials.password == "password":
        return {"message": "Login successful", "role": "patient", "email": credentials.email}
    else:
        raise HTTPException(status_code=401, detail="Invalid patient credentials")

@app.post("/predict")
async def predict_risk(file: UploadFile = File(...)):
    print(f"DEBUG: Received file request: {file.filename}")
    if not model:
        print("DEBUG: Model not loaded!")
        raise HTTPException(status_code=500, detail="Model could not be loaded on the server.")
    
    # Check if file is a CSV
    if not file.filename or not file.filename.lower().endswith('.csv'):
        print(f"DEBUG: Invalid file type: {file.filename}")
        raise HTTPException(status_code=400, detail="Only CSV files containing 187 ECG data signal points are supported.")
    
    try:
        # Read the uploaded file into a Pandas DataFrame with robust parsing for mobile-exported CSVs.
        content = await file.read()
        if not content:
            raise HTTPException(status_code=400, detail="Uploaded file is empty.")

        df = None
        parse_errors = []
        for encoding in ("utf-8", "utf-8-sig", "utf-16", "latin-1"):
            try:
                df = pd.read_csv(
                    io.BytesIO(content),
                    header=None,
                    encoding=encoding,
                    sep=None,
                    engine="python",
                )
                break
            except Exception as parse_error:
                parse_errors.append(f"{encoding}: {parse_error}")

        if df is None:
            raise HTTPException(
                status_code=400,
                detail=f"Could not parse CSV file. Tried multiple encodings. Errors: {' | '.join(parse_errors)}",
            )

        df = df.dropna(how="all")
        df = df.dropna(axis=1, how="all")
        print(f"DEBUG: CSV shape: {df.shape}")

        if df.empty:
            raise HTTPException(status_code=400, detail="CSV has no usable ECG values.")
        
        # Flatten to handle row-wise or column-wise ECG data and coerce non-numeric values.
        values = df.to_numpy().flatten()
        series = pd.to_numeric(pd.Series(values), errors="coerce").dropna().reset_index(drop=True)

        if len(series) < 187:
            raise HTTPException(
                status_code=400,
                detail=f"The CSV file must contain at least 187 numeric ECG values. Found {len(series)} values.",
            )

        features = series.iloc[:187].to_numpy(dtype=np.float32).reshape(1, -1)
        
        # Determine risk using model.predict_proba
        # The model was trained with 0=Normal, 1=Arrhythmia
        # predict_proba returns [[prob_0, prob_1]]
        probas = model.predict_proba(features)[0]
        arrhythmia_probability = probas[1]
        
        # Categorize into Low, Medium, High risk
        if arrhythmia_probability < 0.33:
            risk_level = "Low"
        elif arrhythmia_probability < 0.66:
            risk_level = "Medium"
        else:
            risk_level = "High"
            
        return {
            "filename": file.filename,
            "arrhythmia_probability": float(arrhythmia_probability),
            "risk_level": risk_level,
            "message": f"Based on the ECG signal, the patient has a {risk_level} risk of Arrhythmia."
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"DEBUG TRACEBACK: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=f"An error occurred while processing the file: {str(e)}")

# To run the API server locally:
# uvicorn main:app --reload
