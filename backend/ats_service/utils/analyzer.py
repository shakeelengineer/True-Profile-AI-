import spacy
from rake_nltk import Rake
import json
import nltk
import re
from collections import Counter

# Download NLTK data
try:
    nltk.download('stopwords', quiet=True)
    nltk.download('punkt', quiet=True)
except:
    pass

# Load spaCy
try:
    # Use lg or md if available for better NER, but sm is default for speed
    nlp = spacy.load("en_core_web_sm")
except:
    nlp = None

# Comprehensive Taxonomy for Skills (JustScreen Requirement)
TECH_SKILLS = {
    'programming': ['python', 'java', 'c++', 'c#', 'javascript', 'typescript', 'go', 'rust', 'swift', 'kotlin', 'php', 'ruby', 'dart', 'scala'],
    'frameworks': ['flutter', 'react', 'react native', 'angular', 'vue', 'django', 'flask', 'fastapi', 'spring boot', 'express', 'laravel'],
    'data': ['sql', 'nosql', 'mongodb', 'postgresql', 'mysql', 'oracle', 'pandas', 'numpy', 'scikit-learn', 'tensorflow', 'pytorch', 'tableau', 'power bi'],
    'cloud_devops': ['aws', 'azure', 'gcp', 'docker', 'kubernetes', 'jenkins', 'git', 'github', 'terraform', 'ansible', 'linux'],
    'design': ['figma', 'adobe xd', 'photoshop', 'illustrator', 'ui', 'ux', 'user interface', 'user experience', 'canva'],
    'soft_skills': ['leadership', 'communication', 'teamwork', 'problem solving', 'agile', 'scrum', 'project management', 'management']
}

def is_resume(text):
    """
    Validation: Ensures document is a professional profile.
    Checks for the co-occurrence of structural headers and professional entities.
    """
    headers = ['experience', 'education', 'skills', 'objective', 'summary', 'projects', 'certifications']
    text_lower = text.lower()
    header_count = sum(1 for h in headers if h in text_lower)
    
    # JustScreen requires basic structural integrity
    if header_count < 3:
        return False
        
    # Check for bullet density (characteristic of resumes)
    bullets = len(re.findall(r'[•\-\*]', text))
    if bullets < 5:
        # Some resumes don't use standard bullets, check line count vs char count
        lines = text.split('\n')
        if len(lines) < 10: return False
        
    return True

def extract_information(text):
    if not nlp: return {"error": "Natural Language Processing engine (spaCy) not loaded"}
    
    if not is_resume(text):
        return {"error": "Invalid Document: This does not appear to be a professional Resume or CV. Please ensure you upload a document with clear sections like Education, Experience, and Skills."}

    doc = nlp(text)
    extracted_data = {
        "skills": [], 
        "education": [], 
        "experience": [], 
        "projects": [], 
        "certifications": [],
        "entities": {"orgs": [], "dates": [], "titles": []},
        "keywords": []
    }
    
    # 1. Named Entity Recognition
    for ent in doc.ents:
        if ent.label_ == "ORG":
            extracted_data["entities"]["orgs"].append(ent.text)
        elif ent.label_ == "DATE":
            extracted_data["entities"]["dates"].append(ent.text)

    # Identifies headers with more flexibility (allows numbering, special chars, leading space)
    section_map = {
        "education": r"(?i)^\s*(\d\.|[•\-\*])?\s*(education|academic|studies|qualification|background|scholastic)",
        "experience": r"(?i)^\s*(\d\.|[•\-\*])?\s*(experience|work history|employment|career|internship|professional experience|work experience)",
        "projects": r"(?i)^\s*(\d\.|[•\-\*])?\s*(projects|academic projects|technical projects|personal projects|portfolio)",
        "skills": r"(?i)^\s*(\d\.|[•\-\*])?\s*(skills|technologies|proficiencies|expertise|competencies|technical skills|core competencies)",
        "certifications": r"(?i)^\s*(\d\.|[•\-\*])?\s*(certifications|awards|honors|licenses|achievements|credentials)"
    }
    
    current_section = None
    lines = text.split('\n')
    
    # Pre-scan lines to identify indices of headers
    section_indices = {}
    
    for i, line in enumerate(lines):
        clean_line = line.strip()
        if not clean_line: continue
        
        # Heuristic: Headers are usually short
        if len(clean_line) < 50: 
            found_header = False
            for section, pattern in section_map.items():
                if re.search(pattern, clean_line):
                    # Also check it doesn't look like a sentence
                    if not re.search(r'(have|was|is|are|developed|worked)', clean_line.lower()):
                        current_section = section
                        found_header = True
                        break
            
            if found_header:
                continue # Don't add header itself to content
        
        if current_section:
            extracted_data[current_section].append(clean_line)

    # 3. Explicit Skill Identification via Taxonomy
    text_lower = text.lower()
    for category, skills in TECH_SKILLS.items():
        for skill in skills:
            # Improved regex to catch skills with versions or variations (e.g., Python 3)
            # and prevent matching within words (e.g. "go" in "good")
            pattern = r'(?<!\w)' + re.escape(skill) + r'(?!\w)'
            if re.search(pattern, text_lower):
                extracted_data["skills"].append(skill)
    
    extracted_data["skills"] = list(set(extracted_data["skills"]))

    # 4. Keyword extraction (Fall back to simple frequency if RAKE fails or finds nothing)
    try:
        r = Rake()
        r.extract_keywords_from_text(text)
        extracted_data["keywords"] = r.get_ranked_phrases()[:30]
    except:
        extracted_data["keywords"] = extracted_data["skills"] # Fallback to skills
    
    return extracted_data

def calculate_ats_score(extracted_data, raw_text):
    if "error" in extracted_data:
        return 0, []

    # Weights based on JustScreen Fair Screening Methodology
    weights = {
        "structure": 25,     # Transparency & Completeness
        "skills": 35,        # Relevant Taxonomy Match
        "education": 15,     # Academic Merit
        "experience": 25     # Quantifiable Impact & Duration
    }
    
    score = 0
    feedback_details = {}

    # --- 1. Structure Analysis (25 pts) ---
    required = ["education", "experience", "skills"]
    found = [s for s in required if len(extracted_data.get(s, [])) > 0]
    optional = ["projects", "certifications", "summary"] # Added summary as optional
    found_opt = [s for s in optional if len(extracted_data.get(s, [])) > 0]
    
    # Base score for finding ANY sections
    if len(found) > 0 or len(found_opt) > 0:
        score += 5

    structure_score = (len(found) / len(required)) * 15
    structure_score += (len(found_opt) / len(optional)) * 5 # Adjusted split
    score += structure_score
    
    # --- 2. Skill Taxonomy Match (35 pts) ---
    skills_found = extracted_data.get("skills", [])
    # Target: 6 unique domain-relevant skills for good points (relaxed from 10)
    # If standard skills are low, boost with high keyword count potentially
    skill_count = len(skills_found)
    skill_score = min((skill_count / 8) * 35, 35) # Validated against 8 skills
    score += skill_score
    
    # --- 3. Education Merit (15 pts) ---
    edu_text = " ".join(extracted_data.get("education", [])).lower()
    edu_indicators = ["degree", "bachelor", "master", "phd", "university", "college", "gpa", "graduate", "b.tech", "m.tech", "b.e", "b.s", "diploma", "certified"]
    found_indicators = [i for i in edu_indicators if i in edu_text]
    
    # If education section exists but no specific degree found, still give points for section existence
    base_edu = 5 if len(extracted_data.get("education", [])) > 0 else 0
    edu_content_score = min((len(found_indicators) / 2) * 10, 10)
    score += base_edu + edu_content_score
    
    # --- 4. Experience & Impact (25 pts) ---
    exp_lines = extracted_data.get("experience", []) + extracted_data.get("projects", [])
    exp_text = " ".join(exp_lines).lower()
    
    # Action Verbs (JustScreen: Evidence of action)
    action_verbs = ["developed", "led", "managed", "built", "implemented", "scaled", "optimized", "increased", "decreased", "saved", "launched", "automated", "mentored", "created", "designed", "performed", "achieved"]
    found_verbs = [v for v in action_verbs if v in exp_text]
    verb_points = min((len(found_verbs) / 5) * 15, 15)
    
    # Quantifiable results (Detect numbers/percentages)
    has_metrics = len(re.findall(r'\d+%', exp_text)) > 0 or len(re.findall(r'\d+', exp_text)) > 2
    metric_points = 10 if has_metrics else 5 # Give 5 points just for having text if logic fails
    if len(exp_lines) == 0: metric_points = 0
    
    exp_score = verb_points + metric_points
    score += exp_score
    
    # JustScreen Consistency Check: Penalty for extremely short descriptions
    # Relaxed penalty: Only if VERY short (< 50 words)
    if len(raw_text.split()) < 50:
        score *= 0.8  # 20% penalty
        
    return round(min(score, 100), 1), found + found_opt
