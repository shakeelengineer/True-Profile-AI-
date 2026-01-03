# ATS Resume Screening Module (JustScreen Inspired)

This module is a core part of the **True-Profile AI** project, designed for student-centric resume quality evaluation.

## 🚀 Features
- **File Extraction**: Supports PDF (using PyMuPDF) and DOCX (using python-docx).
- **Bias Reduction**: Automatically removes PII (Emails, Phone Numbers) to ensure fair evaluation focusing on skills.
- **NLP Extraction**: Uses `spaCy` and `RAKE-NLTK` for extracting skills and keywords.
- **Rule-based Scoring**: Implements a transparent scoring logic based on the *JustScreen* methodology (25% Structure, 35% Skills, 20% Education, 20% Experience).
- **Explainable Feedback**: Generates detailed strengths, weaknesses, and suggestions using LLM (OpenAI) with a rule-based fallback.

## 🏗 Architecture
- **Backend**: FastAPI (Python 3.10+)
- **NLP**: spaCy, RAKE-NLTK
- **LLM**: OpenAI GPT-3.5/4 (Optional)

## 🛠 Setup & Installation

1. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   python -m spacy download en_core_web_sm
   ```

2. **Environment Variables**:
   Create a `.env` file in this directory and add:
   ```env
   OPENAI_API_KEY=your_key_here
   ```

3. **Run the Server**:
   ```bash
   python main.py
   ```

## 🔌 API Endpoints

### `POST /analyze-resume`
**Request**: `multipart/form-data` with a `file` field.
**Response**:
```json
{
  "resume_score": 82,
  "skills_detected": ["Python", "Flutter", "..."],
  "strengths": ["...", "...", "..."],
  "weaknesses": ["...", "...", "..."],
  "suggestions": ["...", "...", "..."],
  "ats_feedback": "..."
}
```

## 🎓 Academic Alignment
This implementation follows the **JustScreen: Fair and Ethical Resume Screening** research paper principles:
- **Fairness**: By stripping PII before analysis.
- **Transparency**: Using rule-based scoring instead of a "black-box" ML model.
- **Student-Centric**: Focused on quality and suggestions rather than recruiter ranking.
