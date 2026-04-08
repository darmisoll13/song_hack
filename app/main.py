import os
import shutil
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from .model import predict_chords

app = FastAPI(
    title="Guitar Chord Recognition API",
    description="A simple MLOps pipeline API to predict guitar chords from audio files.",
    version="1.0.0"
)

UPLOAD_DIR = "upload"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.get("/")
def read_root():
    return {"message": "Welcome to the Guitar Chord Recognition API. Use /predict to upload a song."}

@app.post("/predict")
async def predict_audio(file: UploadFile = File(...)):
    if not file.filename.endswith(('.wav', '.mp3', '.ogg', '.flac')):
        raise HTTPException(status_code=400, detail="Invalid file type. Please upload a valid audio file.")
    
    file_path = os.path.join(UPLOAD_DIR, file.filename)
    
    # Save the uploaded file temporarily
    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # Run inference (Mock AI model)
        chords = predict_chords(file_path)
        
        return JSONResponse(content={
            "filename": file.filename,
            "status": "success",
            "predicted_chords": chords
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        # Clean up the file after prediction
        if os.path.exists(file_path):
            os.remove(file_path)
