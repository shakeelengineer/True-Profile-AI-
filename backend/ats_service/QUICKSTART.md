# ATS Service Deployment - Quick Start Guide

## ✅ What's Ready

Your ATS Resume Service is now ready for deployment to **Render.com (Free Plan)**!

### Files Created:
1. ✅ `render.yaml` - Automatic deployment configuration
2. ✅ `DEPLOYMENT.md` - Detailed step-by-step guide
3. ✅ `.env.example` - Environment variables template
4. ✅ `.gitignore` - Prevents committing sensitive files
5. ✅ Updated `requirements.txt` - Pinned versions for stability
6. ✅ Updated `README.md` - Complete documentation

---

## 🚀 Quick Deploy (3 Steps)

### Step 1: Push to GitHub *(if not already done)*
```bash
cd "e:\Documents\AI\True-Profile AI\true_profile_ai"
git add backend/ats_service
git commit -m "Add Render deployment config"
git push origin main
```

### Step 2: Deploy on Render
1. Go to: https://dashboard.render.com/
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository
4. Fill in these settings:
   - **Root Directory**: `backend/ats_service`
   - **Build Command**: `pip install -r requirements.txt && python -m spacy download en_core_web_sm`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
   - **Plan**: Free

### Step 3: Get Your URL
After deployment completes (~5-10 min), you'll get:
```
https://your-service-name.onrender.com
```

Test it by visiting the URL - you should see:
```json
{"message": "True-Profile AI ATS Module v2.0 (Enhanced Scoring) is running!"}
```

---

## 🔧 Update Your Flutter App

Once deployed, update your Flutter API endpoint:

**File**: `lib/features/resume/services/resume_service.dart`

Replace the current URL with your Render URL:
```dart
final String _baseUrl = 'https://your-service-name.onrender.com';
```

---

## ⚠️ Important: Free Tier Notes

- **Spin Down**: Service sleeps after 15 minutes of inactivity
- **Wake Up Time**: First request after sleep takes 30-60 seconds
- **Runtime**: 750 hours/month (plenty for development)
- **Perfect for**: Testing, development, MVPs

---

## 📚 Documentation

- **Quick Reference**: See `.agent/workflows/deploy-render.md`
- **Detailed Guide**: See `backend/ats_service/DEPLOYMENT.md`
- **API Docs**: See `backend/ats_service/README.md`

---

## 🆘 Need Help?

**Build Fails?**
- Check Render dashboard logs
- Verify `requirements.txt` is accessible
- Ensure Python 3.11 is selected

**Service Errors?**
- Check environment variables in Render dashboard
- Review service logs
- Test locally first: `python main.py`

**Flutter Connection Issues?**
- Verify URL is correct (with https://)
- Check for CORS errors in browser console
- Remember: First request after sleep takes longer

---

## 🎯 Next Steps

1. ✅ Deploy to Render (follow steps above)
2. ✅ Test the API endpoints
3. ✅ Update Flutter app with new URL
4. ✅ Test end-to-end from Flutter app
5. ✅ (Optional) Add OpenAI API key for enhanced feedback

---

**Ready to deploy? Follow the steps above or see DEPLOYMENT.md for detailed instructions!**
