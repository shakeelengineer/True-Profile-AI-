---
description: Deploy ATS service to Render.com
---

# Deploy ATS Resume Service to Render.com (Free Plan)

## Quick Deployment Steps

### 1. Ensure code is pushed to GitHub
```bash
cd backend/ats_service
git add .
git commit -m "Prepare for Render deployment"
git push origin main
```

### 2. Go to Render Dashboard
- Visit: https://dashboard.render.com/
- Click **"New +"** → **"Web Service"**

### 3. Connect Repository
- Connect GitHub account
- Select your repository
- Click **"Connect"**

### 4. Configure Service
Fill in these settings:
- **Name**: `ats-resume-service`
- **Region**: Choose closest region
- **Branch**: `main`
- **Root Directory**: `backend/ats_service`
- **Environment**: `Python 3`
- **Build Command**: 
  ```
  pip install -r requirements.txt && python -m spacy download en_core_web_sm
  ```
- **Start Command**: 
  ```
  uvicorn main:app --host 0.0.0.0 --port $PORT
  ```
- **Plan**: **Free**

### 5. Add Environment Variables (Optional)
- Key: `OPENAI_API_KEY`
- Value: Your OpenAI API key (service works without it using fallback feedback)

### 6. Deploy
- Click **"Create Web Service"**
- Wait 5-10 minutes for first deployment
- Get your URL: `https://ats-resume-service.onrender.com`

### 7. Test Deployment
Visit your URL - you should see:
```json
{"message": "True-Profile AI ATS Module v2.0 (Enhanced Scoring) is running!"}
```

### 8. Update Flutter App
Update the API endpoint in your Flutter app:
```dart
final String baseUrl = 'https://your-service-name.onrender.com';
```

## Important Notes
- ⚠️ Free tier spins down after 15 min of inactivity
- ⚠️ First request after sleep takes 30-60 seconds
- ✅ Perfect for development and testing
- ✅ 750 hours/month free runtime

## Alternative: Blueprint Deployment
1. Go to **"Blueprint"** instead of "Web Service"
2. Connect repository
3. Render auto-detects `render.yaml`
4. Click **"Apply"**

Done! 🚀
