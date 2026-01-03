import os
import openai

openai.api_key = os.getenv("OPENAI_API_KEY")

def generate_feedback(score, extracted_data):
    if not openai.api_key:
        return get_fallback_feedback(score, extracted_data)
    
    prompt = f"Analyze resume with score {score}/100 and data {extracted_data}. Provide strengths, weaknesses, suggestions, and summary in JSON."
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}]
        )
        return response.choices[0].message.content
    except:
        return get_fallback_feedback(score, extracted_data)

def get_fallback_feedback(score, extracted_data):
    return {
        "strengths": ["Clear structure", "Industry keywords used"],
        "weaknesses": ["Lack of quantification", "Brief experience details"],
        "suggestions": ["Add metrics/numbers", "Expand on project results"],
        "summary": f"Your resume shows solid potential with a score of {score}/100."
    }
