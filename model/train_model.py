import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix
import joblib
import os

print("Arrhythmia Prediction Model Training Script")
print("===========================================")

# File paths
DATA_DIR = r"e:\Hackathon\dataset"
TRAIN_FILE = os.path.join(DATA_DIR, "mitbih_train.csv")
TEST_FILE = os.path.join(DATA_DIR, "mitbih_test.csv")
MODEL_DIR = r"e:\Hackathon\model"
MODEL_PATH = os.path.join(MODEL_DIR, "arrhythmia_rf_model.pkl")

print(f"Loading training data from: {TRAIN_FILE}...")
# The dataset doesn't have a header row
df_train = pd.read_csv(TRAIN_FILE, header=None)

print(f"Loading test data from: {TEST_FILE}...")
df_test = pd.read_csv(TEST_FILE, header=None)

# The last column is the label
X_train = df_train.iloc[:, :-1].values
y_train_raw = df_train.iloc[:, -1].values

X_test = df_test.iloc[:, :-1].values
y_test_raw = df_test.iloc[:, -1].values

# Convert multiclass labels to binary labels
# Original labels:
# 0: Normal
# 1, 2, 3, 4: Different types of arrhythmias (Supraventricular, Ventricular, Fusion, Unknown)
print("Converting to binary classification: 0 (Normal) vs 1 (Arrhythmia)...")
y_train = (y_train_raw != 0.0).astype(int)
y_test = (y_test_raw != 0.0).astype(int)

# Print class distribution
print(f"Train set - Normal beats: {np.sum(y_train == 0)}, Arrhythmia beats: {np.sum(y_train == 1)}")
print(f"Test set - Normal beats: {np.sum(y_test == 0)}, Arrhythmia beats: {np.sum(y_test == 1)}")

print("\nInitializing Random Forest Classifier...")
# We limit max_depth or n_estimators slightly if we want it to be fast, but default 100 is fine usually.
# Using n_jobs=-1 to train using all CPU cores for speed
clf = RandomForestClassifier(n_estimators=100, random_state=42, n_jobs=-1)

print("Training the model (this might take a few minutes)...")
clf.fit(X_train, y_train)
print("Training completed!")

print("\nEvaluating model on the test set...")
y_pred = clf.predict(X_test)

acc = accuracy_score(y_test, y_pred)
print(f"Accuracy: {acc * 100:.2f}%\n")

print("Classification Report:")
print(classification_report(y_test, y_pred, target_names=["Normal", "Arrhythmia"]))

print("Confusion Matrix:")
print(confusion_matrix(y_test, y_pred))

print(f"\nSaving the trained model to {MODEL_PATH}...")
joblib.dump(clf, MODEL_PATH)
print("Model created and saved successfully!")
