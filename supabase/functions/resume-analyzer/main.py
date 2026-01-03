from supabase_functions import serve
from fastapi import Request, Response
import os
import json

from .utils.extractor import extract_resume_text
from .utils.preprocessor import preprocess_text
from .utils.analyzer import extract_information, calculate_ats_score
from .utils.explainer import generate_feedback, get_fallback_feedback

# This is the entry point for the Supabase Edge Function
@serve
async def main(req: Request):
    if req.method == "OPTIONS":
        return Response(status_code=204)

    try:
        # Read raw bytes directly from request body
        content = await req.body()
        
        if not content:
            return Response(
                content=json.dumps({"error": "No file content received"}),
                status_code=400,
                media_type="application/json"
            )

        # Detect extension from header (passed from Flutter)
        extension = req.headers.get("x-filename", "resume.pdf").lower()
        if not extension.endswith(".pdf") and not extension.endswith(".docx"):
            # fallback based on basic magic check or default
            extension = ".pdf"

        # 1. Extraction
        raw_text = extract_resume_text(content, extension)
        
        # 2. Preprocessing (Bias Reduction)
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
        result = {
            "resume_score": score,
            "skills_detected": extracted_data.get("keywords", []),
            "sections_found": sections_found,
            "strengths": feedback.get("strengths", []),
            "weaknesses": feedback.get("weaknesses", []),
            "suggestions": feedback.get("suggestions", []),
            "ats_feedback": feedback.get("summary", ""),
            "status": "success"
        }

        return Response(
            content=json.dumps(result),
            media_type="application/json"
        )

    except Exception as e:
        return Response(
            content=json.dumps({"error": str(e)}),
            status_code=500,
            media_type="application/json"
        )
