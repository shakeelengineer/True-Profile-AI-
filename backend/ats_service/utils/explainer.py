import os
import openai
import json

openai.api_key = os.getenv("OPENAI_API_KEY")

def generate_feedback(score, extracted_data):
    if "error" in extracted_data:
        return {
            "strengths": [],
            "weaknesses": ["Invalid Document Type"],
            "suggestions": ["Please upload a professional Resume or CV in PDF/DOCX format."],
            "summary": extracted_data["error"]
        }

    if not openai.api_key:
        return get_fallback_feedback(score, extracted_data)
    
    prompt = f"""
    You are an expert ATS (Applicant Tracking System) Analyzer. 
    Analyze the following resume data and provide critical, high-quality feedback.
    
    ATS Score: {score}/100
    Sections Found: {list(extracted_data.keys())}
    Detected Skills/Keywords: {extracted_data.get('keywords', [])[:15]}
    Experience Summary: {" ".join(extracted_data.get('experience', []))[:500]}
    
    Return a JSON object with exactly these keys:
    - "strengths": List of 3 specific things done well.
    - "weaknesses": List of 3 specific areas needing improvement.
    - "suggestions": List of 3 actionable steps to increase the score.
    - "summary": A 2-sentence professional executive summary.
    
    Be critical and realistic. If the score is low, explain why specifically based on the data.
    """
    
    try:
        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a professional career coach and ATS optimization expert."},
                {"role": "user", "content": prompt}
            ],
            response_format={ "type": "json_object" }
        )
        return json.loads(response.choices[0].message.content)
    except Exception as e:
        print(f"LLM Error: {e}")
        return get_fallback_feedback(score, extracted_data)

def get_fallback_feedback(score, extracted_data):
    """
    Generates rule-based feedback based on specific missing elements in the data.
    """
    strengths = []
    weaknesses = []
    suggestions = []
    
    # --- Analyze Structure ---
    missing_sections = []
    for sec in ["experience", "education", "skills"]:
        if not extracted_data.get(sec):
            missing_sections.append(sec.capitalize())
        else:
            strengths.append(f"Clear {sec.capitalize()} section")

    if missing_sections:
        weaknesses.append(f"Missing core sections: {', '.join(missing_sections)}")
        suggestions.append(f"Add dedicated {' and '.join(missing_sections)} sections to improve parsability.")

    # --- Analyze Skills ---
    skill_count = len(extracted_data.get("skills", []))
    if skill_count > 5:
        strengths.append(f"Detected {skill_count} relevant technical skills")
    elif skill_count > 0:
         weaknesses.append("Low count of recognized technical skills")
         suggestions.append("Add more specific technical skills (e.g., specific languages, tools, frameworks) to the Skills section.")
    else:
        weaknesses.append("No technical skills detected")
        suggestions.append("Create a dedicated Skills section and list your top technical competencies.")

    # --- Analyze Content Quality ---
    exp_len = sum(len(x) for x in extracted_data.get("experience", []))
    if exp_len > 500:
        strengths.append("Good amount of detail in Experience")
    elif exp_len < 100 and "Experience" not in missing_sections:
        weaknesses.append("Experience descriptions are too brief")
        suggestions.append("Expand on your work experience with bullet points describing your specific contributions.")

    # Formatting/General
    if score < 40:
        if not weaknesses: weaknesses.append("Content may be poorly formatted or unreadable")
        summary = "Your resume is struggling to pass basic ATS filters. Focus on standard headings and clear text formatting."
    elif score < 70:
        summary = "Your resume has good bones but needs more specific keywords and detailed descriptions to rank higher."
    else:
        strengths.append("Strong overall ATS compatibility")
        summary = "This is a competitive resume. Focus on tailoring it to the specific job description for maximum impact."

    # Fillers if empty
    if not strengths: strengths.append("Basic contact info detected")
    if not weaknesses: weaknesses.append("Could not identify specific weaknesses, but score is low")
    if not suggestions: suggestions.append("Review standard resume templates for best practices.")

    return {
        "strengths": strengths[:3],
        "weaknesses": weaknesses[:3],
        "suggestions": suggestions[:3],
        "summary": summary
    }
