import uvicorn
import os
import json
from typing import List
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

try:
    import cv2
    import numpy as np
    from insightface.app import FaceAnalysis
    FACE_RECOGNITION_AVAILABLE = True
except ImportError:
    FACE_RECOGNITION_AVAILABLE = False
    print("Warning: InsightFace or OpenCV not found. Identity verification will be disabled.")

# ATS Utils
from utils.extractor import extract_resume_text
from utils.preprocessor import preprocess_text
from utils.analyzer import extract_information, calculate_ats_score
from utils.explainer import generate_feedback, get_fallback_feedback
from utils.quiz_generator import generate_quiz

app = FastAPI(title="True-Profile AI Unified Backend", description="ATS + Skills + Identity Verification")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Identity Verification Setup ---
# Initialize FaceAnalysis with Buffalo_L model
try:
    face_analyzer = FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])
    face_analyzer.prepare(ctx_id=0, det_size=(640, 640))
except Exception as e:
    print(f"Warning: InsightFace initialization failed. Identity verification may not work: {e}")
    face_analyzer = None

def get_embedding(image_bytes):
    if face_analyzer is None:
        raise HTTPException(status_code=503, detail="Face analysis service is unavailable.")
        
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if img is None:
        raise HTTPException(status_code=400, detail="Could not decode image.")

    faces = face_analyzer.get(img)
    if not faces:
        return None
    
    # Return embedding of the largest face
    best_face = max(faces, key=lambda x: (x.bbox[2]-x.bbox[0]) * (x.bbox[3]-x.bbox[1]))
    return best_face.normed_embedding

@app.get("/")
async def root():
    return {"message": "True-Profile AI Unified Backend is running!"}

# --- ATS Endpoints ---
@app.post("/analyze-resume")
async def analyze_resume(file: UploadFile = File(...)):
    extension = os.path.splitext(file.filename)[1]
    if extension.lower() not in [".pdf", ".docx", ".doc"]:
        raise HTTPException(status_code=400, detail="Only PDF and DOCX files are supported.")

    try:
        content = await file.read()
        raw_text = extract_resume_text(content, extension)
        clean_text = preprocess_text(raw_text)
        extracted_data = extract_information(clean_text)
        score, sections_found = calculate_ats_score(extracted_data, clean_text)
        feedback = generate_feedback(score, extracted_data)
        
        if isinstance(feedback, str):
            try:
                feedback = json.loads(feedback)
            except:
                feedback = get_fallback_feedback(score, extracted_data)

        return {
            "resume_score": score,
            "skills_detected": extracted_data.get("skills", []) if "skills" in extracted_data else extracted_data.get("keywords", []),
            "sections_found": sections_found,
            "strengths": feedback.get("strengths", []),
            "weaknesses": feedback.get("weaknesses", []),
            "suggestions": feedback.get("suggestions", []),
            "ats_feedback": feedback.get("summary", ""),
            "status": "success"
        }
    except Exception as e:
        print(f"ATS Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# --- Skills Endpoints ---
class QuizRequest(BaseModel):
    skill: str
    num_questions: int = 10

@app.post("/generate-quiz")
async def generate_skill_quiz(request: QuizRequest):
    try:
        if not request.skill or len(request.skill.strip()) == 0:
            raise HTTPException(status_code=400, detail="Skill name is required")
        
        quiz_data = generate_quiz(request.skill.strip(), request.num_questions)
        return {
            "status": "success",
            "skill": quiz_data['skill'],
            "total_questions": quiz_data['total_questions'],
            "passing_score": quiz_data['passing_score'],
            "questions": quiz_data['questions']
        }
    except Exception as e:
        print(f"Quiz Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# --- Identity Verification Endpoints ---
@app.post("/verify-face")
async def verify_face(
    selfie: UploadFile = File(...),
    references: List[UploadFile] = File(...)
):
    if not FACE_RECOGNITION_AVAILABLE:
        return {"verified": False, "error": "Face Recognition engine not installed on server."}
        
    try:
        selfie_emb = get_embedding(await selfie.read())
        if selfie_emb is None:
            return {"verified": False, "error": "No face detected in selfie image."}

        best_score = 0.0
        for ref_file in references:
            ref_emb = get_embedding(await ref_file.read())
            if ref_emb is not None:
                score = np.dot(selfie_emb, ref_emb)
                if score > best_score:
                    best_score = score

        return {
            "verified": float(best_score) >= 0.75,
            "confidence": float(best_score)
        }
    except Exception as e:
        print(f"Identity Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
