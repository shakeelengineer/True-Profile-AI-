import spacy
from rake_nltk import Rake
import json
import nltk

# Download NLTK data
try:
    nltk.download('stopwords', quiet=True)
    nltk.download('punkt', quiet=True)
except:
    pass

# Load spaCy
try:
    nlp = spacy.load("en_core_web_sm")
except:
    nlp = None

def extract_information(text):
    if not nlp: return {"error": "spaCy model not loaded"}
    doc = nlp(text)
    extracted_data = {"skills": [], "education": [], "experience": [], "projects": [], "keywords": []}
    
    r = Rake()
    r.extract_keywords_from_text(text)
    extracted_data["keywords"] = r.get_ranked_phrases()[:15]
    
    sections = ["EDUCATION", "EXPERIENCE", "PROJECTS", "SKILLS", "CERTIFICATIONS"]
    current_section = None
    for line in text.split('\n'):
        clean_line = line.strip().upper()
        if any(section in clean_line for section in sections):
            current_section = clean_line
            continue
        if current_section:
            if "EDUCATION" in current_section: extracted_data["education"].append(line.strip())
            elif "EXPERIENCE" in current_section: extracted_data["experience"].append(line.strip())
            elif "PROJECTS" in current_section: extracted_data["projects"].append(line.strip())
            elif "SKILLS" in current_section: extracted_data["skills"].append(line.strip())
    return extracted_data

def calculate_ats_score(extracted_data, raw_text):
    score = 0
    required_sections = ["education", "experience", "skills"]
    found_sections = [s for s in required_sections if extracted_data.get(s)]
    score += (len(found_sections) / len(required_sections)) * 25
    
    skill_count = len(extracted_data.get("skills", []))
    keyword_count = len(extracted_data.get("keywords", []))
    score += min(((skill_count + keyword_count) / 20) * 35, 35)
    
    edu_text = " ".join(extracted_data.get("education", []))
    edu_keywords = ["degree", "bachelor", "master", "university", "college"]
    found_edu = [k for k in edu_keywords if k in edu_text.lower()]
    score += min((len(found_edu) / 3) * 20, 20)
    
    exp_text = " ".join(extracted_data.get("experience", []) + extracted_data.get("projects", []))
    action_verbs = ["developed", "managed", "built", "implemented", "created"]
    found_verbs = [v for v in action_verbs if v in exp_text.lower()]
    score += min((len(found_verbs) / 5) * 20, 20)
    
    return round(score, 2), found_sections
