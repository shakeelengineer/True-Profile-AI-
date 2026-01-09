# Deploy ATS Resume Service to Render.com (Free Plan)

This guide will walk you through deploying the True-Profile AI ATS Resume Service to Render.com's free tier.

## Prerequisites

1. A [Render.com](https://render.com) account (sign up is free)
2. A GitHub account
3. Your code pushed to a GitHub repository
4. (Optional) An OpenAI API key for enhanced feedback

## Deployment Steps

### Step 1: Push Code to GitHub

1. Make sure your code is in a GitHub repository
2. The `backend/ats_service` folder should be accessible in your repo

### Step 2: Create a New Web Service on Render

1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click **"New +"** button in the top right
3. Select **"Web Service"**

### Step 3: Connect Repository

1. Connect your GitHub account if not already connected
2. Search for and select your repository: `True-Profile-AI` or similar
3. Click **"Connect"**

### Step 4: Configure the Service

Use these settings:

- **Name**: `ats-resume-service` (or your preferred name)
- **Region**: Choose the closest region to your users
- **Branch**: `main` (or your default branch)
- **Root Directory**: `backend/ats_service`
- **Environment**: `Python 3`
- **Build Command**: 
  ```bash
  pip install -r requirements.txt && python -m spacy download en_core_web_sm
  ```
- **Start Command**: 
  ```bash
  uvicorn main:app --host 0.0.0.0 --port $PORT
  ```
- **Plan**: Select **"Free"**

### Step 5: Add Environment Variables (Optional)

1. Scroll down to **"Environment Variables"**
2. Click **"Add Environment Variable"**
3. Add the following:
   - **Key**: `OPENAI_API_KEY`
   - **Value**: Your OpenAI API key (if you have one)

**Note**: The service will work without an API key by using fallback rule-based feedback.

### Step 6: Deploy

1. Click **"Create Web Service"**
2. Render will start building and deploying your service
3. Wait for the build to complete (first deployment takes 5-10 minutes)
4. Once deployed, you'll get a URL like: `https://ats-resume-service.onrender.com`

### Step 7: Test Your Deployment

1. Visit your service URL in a browser
2. You should see: `{"message": "True-Profile AI ATS Module v2.0 (Enhanced Scoring) is running!"}`
3. Test the API using the endpoint: `POST /analyze-resume`

## Important Notes for Free Plan

⚠️ **Free Tier Limitations**:
- Your service will **spin down after 15 minutes** of inactivity
- First request after spin-down may take **30-60 seconds** to wake up
- 750 hours/month of free runtime
- Service sleeps after inactivity - perfect for development/testing

## Updating Your Flutter App

Once deployed, update your Flutter app's API endpoint:

```dart
// In resume_service.dart or your API configuration
final String baseUrl = 'https://your-service-name.onrender.com';
```

## API Endpoints

- **Health Check**: `GET /`
- **Analyze Resume**: `POST /analyze-resume` (multipart/form-data with file)

## Troubleshooting

### Build Fails
- Check that all dependencies in `requirements.txt` are compatible
- Review build logs in Render dashboard

### Service Timeout
- Free tier spins down after inactivity
- First request after sleep takes longer - this is normal

### API Errors
- Check environment variables are set correctly
- Review service logs in Render dashboard

## Alternative: Using render.yaml

For easier deployment, you can use the included `render.yaml` file:

1. In Render dashboard, go to **"Blueprint"** instead of "Web Service"
2. Connect repository
3. Render will automatically detect and use `render.yaml`
4. Click "Apply" to deploy with the configured settings

## Cost Optimization

The free plan is perfect for:
- Development and testing
- Low-traffic applications
- Proof of concepts
- Personal projects

For production use with consistent traffic, consider upgrading to a paid plan.

## Support

For issues specific to Render.com deployment, check:
- [Render Documentation](https://render.com/docs)
- [Render Community](https://community.render.com)

For ATS service issues, check the logs in your Render dashboard.
