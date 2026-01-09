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

## 🛠 Local Setup & Installation

1. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   python -m spacy download en_core_web_sm
   ```

2. **Environment Variables** (Optional):
   Create a `.env` file in this directory and add:
   ```env
   OPENAI_API_KEY=your_key_here
   ```
   Note: Service works without API key using rule-based fallback.

3. **Run the Server**:
   ```bash
   python main.py
   ```
   Server will be available at `http://localhost:8000`

## ☁️ Deployment to Render.com (Free Plan)

Deploy this service to Render.com for free! See **[DEPLOYMENT.md](./DEPLOYMENT.md)** for detailed step-by-step instructions.

**Quick Deploy**:
1. Push code to GitHub
2. Go to [Render Dashboard](https://dashboard.render.com/)
3. Create new Web Service
4. Use these commands:
   - Build: `pip install -r requirements.txt && python -m spacy download en_core_web_sm`
   - Start: `uvicorn main:app --host 0.0.0.0 --port $PORT`
5. Deploy! 🚀

Your service will be live at: `https://your-service-name.onrender.com`

## 🔌 API Endpoints

### Health Check
```
GET /
```
Returns service status.

### Analyze Resume
```
POST /analyze-resume
```
**Request**: `multipart/form-data` with a `file` field (PDF or DOCX).

**Response**:
```json
{
  "resume_score": 82,
  "skills_detected": ["Python", "Flutter", "..."],
  "sections_found": ["experience", "education", "skills"],
  "strengths": ["...", "...", "..."],
  "weaknesses": ["...", "...", "..."],
  "suggestions": ["...", "...", "..."],
  "ats_feedback": "...",
  "status": "success"
}
```

## 🎓 Academic Alignment
This implementation follows the **JustScreen: Fair and Ethical Resume Screening** research paper principles:
- **Fairness**: By stripping PII before analysis.
- **Transparency**: Using rule-based scoring instead of a "black-box" ML model.
- **Student-Centric**: Focused on quality and suggestions rather than recruiter ranking.

## 📁 Project Structure
```
ats_service/
├── main.py              # FastAPI application entry point
├── requirements.txt     # Python dependencies
├── render.yaml          # Render.com deployment config
├── DEPLOYMENT.md        # Detailed deployment guide
├── .env.example         # Environment variables template
└── utils/
    ├── extractor.py     # PDF/DOCX text extraction
    ├── preprocessor.py  # Text cleaning & PII removal
    ├── analyzer.py      # NLP analysis & scoring
    └── explainer.py     # Feedback generation (LLM + fallback)
```

## 🔧 Troubleshooting

**Service won't start?**
- Ensure all dependencies are installed
- Check if spaCy model is downloaded: `python -m spacy download en_core_web_sm`

**Low scores for all resumes?**
- Check if the resume has standard sections (Experience, Education, Skills)
- Ensure text is extractable (not scanned images)

**Deployment issues?**
- See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed troubleshooting
- Check Render dashboard logs for build errors

