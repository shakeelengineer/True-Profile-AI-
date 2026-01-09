from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
import os
import json

from utils.extractor import extract_resume_text
from utils.preprocessor import preprocess_text
from utils.analyzer import extract_information, calculate_ats_score
from utils.explainer import generate_feedback, get_fallback_feedback
from utils.quiz_generator import generate_quiz

app = FastAPI(title="True-Profile AI ATS Module", description="Local ATS Backend")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "True-Profile AI ATS Module v2.0 (Enhanced Scoring) is running!"}

@app.post("/analyze-resume")
async def analyze_resume(file: UploadFile = File(...)):
    """
    Main endpoint for resume analysis.
    """
    # Validate file type
    extension = os.path.splitext(file.filename)[1]
    if extension.lower() not in [".pdf", ".docx", ".doc"]:
        raise HTTPException(status_code=400, detail="Only PDF and DOCX files are supported.")

    try:
        # Read file bytes
        content = await file.read()
        
        # 1. Extraction
        raw_text = extract_resume_text(content, extension)
        
        # 2. Preprocessing & Bias Reduction
        clean_text = preprocess_text(raw_text)
        
        # 3. NLP Extraction
        extracted_data = extract_information(clean_text)
        
        # 4. ATS Scoring
        score, sections_found = calculate_ats_score(extracted_data, clean_text)
        
        # 5. Explainable Feedback
        feedback = generate_feedback(score, extracted_data)
        
        if isinstance(feedback, str):
            try:
                feedback = json.loads(feedback)
            except:
                feedback = get_fallback_feedback(score, extracted_data)

        # Structure response
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
        print(f"Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

class QuizRequest(BaseModel):
    skill: str
    num_questions: int = 10

@app.post("/generate-quiz")
async def generate_skill_quiz(request: QuizRequest):
    """
    Generate quiz questions for a specific skill.
    """
    try:
        if not request.skill or len(request.skill.strip()) == 0:
            raise HTTPException(status_code=400, detail="Skill name is required")
        
        # Generate quiz with the specified number of questions
        quiz_data = generate_quiz(request.skill.strip(), request.num_questions)
        
        return {
            "status": "success",
            "skill": quiz_data['skill'],
            "total_questions": quiz_data['total_questions'],
            "passing_score": quiz_data['passing_score'],
            "questions": quiz_data['questions']
        }
    
    except Exception as e:
        print(f"Error generating quiz: {e}")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    # Host 0.0.0.0 is crucial for identifying from external devices
    uvicorn.run(app, host="0.0.0.0", port=8000)
