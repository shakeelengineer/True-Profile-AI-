# 🚀 Render.com Deployment - Step-by-Step Guide

## ✅ What You've Done So Far

1. ✅ Code is on GitHub: https://github.com/shakeelengineer/True-Profile-AI-
2. ✅ Smart fallback added to Flutter app (Render → Local)
3. ✅ Deployment files ready (render.yaml, requirements.txt, etc.)

---

## 📋 Next Steps: Deploy to Render.com

### Step 1: Log in to Render.com

1. Open your browser and go to: **https://dashboard.render.com/**
2. **Log in** with your account (or sign up if you don't have one)
   - You can sign up with GitHub (recommended for easier repo connection)

---

### Step 2: Create New Web Service

1. Once logged in, click the **"New +"** button (top right corner)
2. Select **"Web Service"** from the dropdown menu

![New Web Service](https://docs.render.com/images/create-web-service.png)

---

### Step 3: Connect Your GitHub Repository

1. If this is your first time, click **"Connect GitHub"**
   - Authorize Render to access your GitHub repositories
   
2. Search for your repository: **"True-Profile-AI-"**
3. Click **"Connect"** next to your repository

---

### Step 4: Configure Your Service

Fill in the following settings:

#### **Basic Settings**
- **Name**: `ats-resume-service` (or any name you prefer)
- **Region**: Choose closest to you (e.g., Singapore, Frankfurt, Oregon)
- **Branch**: `main` (or your default branch)
- **Root Directory**: `backend/ats_service`

#### **Build & Deploy**
- **Runtime**: `Python 3`
- **Build Command**:
  ```bash
  pip install -r requirements.txt && python -m spacy download en_core_web_sm
  ```
- **Start Command**:
  ```bash
  uvicorn main:app --host 0.0.0.0 --port $PORT
  ```

#### **Plan**
- **Instance Type**: Select **"Free"**
  - ⚠️ Note: Free tier spins down after 15 min of inactivity
  - ⚠️ Cold start takes 30-60 seconds

---

### Step 5: Add Environment Variables (Optional)

Scroll down to **"Environment Variables"** section:

1. Click **"Add Environment Variable"**
2. Add:
   - **Key**: `OPENAI_API_KEY`
   - **Value**: Your OpenAI API key (if you have one)

**Note**: Service works WITHOUT this key using fallback feedback.

---

### Step 6: Deploy!

1. Click **"Create Web Service"** button at the bottom
2. Render will start building your service
3. **Wait 5-10 minutes** for the first deployment
   - You can watch the build logs in real-time
   - Look for: ✅ "Build successful"
   - Then: ✅ "Deploy live"

---

### Step 7: Get Your Service URL

Once deployed, you'll see:
- **Status**: "Live" (green dot)
- **URL**: `https://ats-resume-service.onrender.com`

**Copy this URL!** You'll need it for the next step.

---

### Step 8: Test Your Deployment

1. Open your service URL in a browser
2. You should see:
   ```json
   {"message": "True-Profile AI ATS Module v2.0 (Enhanced Scoring) is running!"}
   ```

✅ **Success!** Your service is now live on Render.com!

---

## 🔧 Update Your Flutter App

Now update your Flutter code with the Render URL:

### File: `lib/features/resume/services/resume_service.dart`

Find this line (around line 27):
```dart
static const String _renderUrl = 'https://ats-resume-service.onrender.com';
```

**Replace with YOUR actual Render URL:**
```dart
static const String _renderUrl = 'https://YOUR-SERVICE-NAME.onrender.com';
```

**Example:**
If your URL is `https://ats-resume-service-abc123.onrender.com`, use:
```dart
static const String _renderUrl = 'https://ats-resume-service-abc123.onrender.com';
```

---

## 🧪 Testing the Smart Fallback

Your Flutter app now has **automatic fallback**:

### Test 1: Render Only
```dart
static const bool _useRender = true;  // Default
```
- ✅ Tries Render first
- ✅ Falls back to local if Render fails

### Test 2: Local Only (Development)
```dart
static const bool _useRender = false;
```
- ✅ Uses only local server
- ✅ Good for offline development

### Test 3: Both Available
- ✅ Uses Render (faster for you)
- ✅ Local server stays as backup

---

## 📊 How the Fallback Works

```
User uploads resume
       ↓
Try Render.com (120s timeout)
  ├─ ✅ Success → Return result
  └─ ❌ Failed → Try Local Server (90s timeout)
       ├─ ✅ Success → Return result
       └─ ❌ Failed → Show error
```

**Console Output:**
```
🌐 Attempting to connect to Render.com...
⚠️ Render.com failed: TimeoutException...
🔄 Falling back to local server...
🏠 Attempting to connect to local server at http://192.168.10.6:8000...
✅ Successfully analyzed via local server
```

---

## ⚠️ Important Notes

### Free Tier Behavior
- **Cold Start**: First request after 15 min takes 30-60 seconds
- **Your app handles this**: 120s timeout + automatic fallback
- **User experience**: Seamless! They won't notice the wait

### When to Use Local Server
- ❌ Render is down
- ❌ Render cold start is too slow
- ✅ You're testing new features locally
- ✅ You're offline

### When Render is Better
- ✅ Accessible anywhere (not just same network)
- ✅ HTTPS (secure)
- ✅ No need to run local server
- ✅ Professional URL for sharing

---

## 🔄 Future Updates

When you update your code:

1. **Push to GitHub**:
   ```bash
   git add .
   git commit -m "Update ATS service"
   git push origin main
   ```

2. **Render auto-deploys** (if you enable auto-deploy)
   - Or manually deploy from Render dashboard

3. **Local server** still works for instant testing!

---

## 🆘 Troubleshooting

### Build Fails on Render
- Check build logs in Render dashboard
- Common issues:
  - ❌ Wrong root directory
  - ❌ Missing dependencies
  - ❌ Python version mismatch

### Service Won't Start
- Check deploy logs for errors
- Verify start command is correct
- Ensure `main:app` exists in main.py

### Flutter Can't Connect
1. Test Render URL in browser first
2. Check if service is "Live" in Render dashboard
3. Verify URL in Flutter code matches Render URL
4. Check Flutter console for error messages

### Both Servers Fail
- Render: Check if service is sleeping (green dot = live)
- Local: Ensure `python main.py` is running
- Flutter: Check error message for details

---

## 💰 Upgrading to Paid Plan

When you're ready (after 1 month on free tier):

1. Go to Render dashboard
2. Click on your service
3. Go to "Settings" → "Plan"
4. Upgrade to **Starter** ($7/month)
   - ✅ No sleep/cold starts
   - ✅ Faster response times
   - ✅ More reliable

**Your fallback will still work!** Just in case.

---

## ✅ Checklist

- [ ] Logged in to Render.com
- [ ] Created new Web Service
- [ ] Connected GitHub repository
- [ ] Configured build/start commands
- [ ] Selected Free plan
- [ ] Deployed successfully
- [ ] Got service URL
- [ ] Tested URL in browser
- [ ] Updated Flutter app with URL
- [ ] Tested from Flutter app
- [ ] Verified fallback works

---

**Need visual guide? Check the screenshots in the deployment folder!**

---

## 📞 Get Help

- **Render Issues**: https://community.render.com
- **Build Errors**: Check Render dashboard logs
- **Flutter Issues**: Check console output
- **This project**: Create issue on GitHub

---

**You're all set! 🎉 Deploy and test your smart fallback system!**
