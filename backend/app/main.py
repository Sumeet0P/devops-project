from fastapi import FastAPI
import os

app = FastAPI()

APP_MESSAGE = os.getenv("APP_MESSAGE", "Hi Sumeet This Side!! 🚀")

@app.get("/")
def root():
    return {"status": "Backend running"}

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/ready")
def ready():
    return {"status": "ready"}

@app.get("/api/message")
def get_message():
    return {"message": APP_MESSAGE}
