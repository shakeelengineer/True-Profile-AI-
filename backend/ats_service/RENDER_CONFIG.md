# ⚡ Render.com Quick Config Reference

## Copy-Paste Configuration for Render Dashboard

### 📍 Service Location
**Root Directory:**
```
backend/ats_service
```

### 🔨 Build Command
```bash
pip install -r requirements.txt && python -m spacy download en_core_web_sm
```

### ▶️ Start Command
```bash
uvicorn main:app --host 0.0.0.0 --port $PORT
```

### 🌍 Environment Variables (Optional)
| Key | Value | Required? |
|-----|-------|-----------|
| `OPENAI_API_KEY` | Your OpenAI API key | No (has fallback) |
| `PYTHON_VERSION` | 3.11.0 | Auto-detected |

---

## 📝 Service Settings

- **Name**: `ats-resume-service` (or your choice)
- **Region**: Choose closest to you
- **Branch**: `main`
- **Runtime**: Python 3
- **Plan**: Free ($0/month)

---

## 🔗 After Deployment

Update Flutter app with your Render URL:

**File**: `lib/features/resume/services/resume_service.dart` (Line ~27)

```dart
static const String _renderUrl = 'https://YOUR-SERVICE-NAME.onrender.com';
```

Replace `YOUR-SERVICE-NAME` with your actual service URL from Render dashboard.

---

## ⚙️ Configuration Options in Flutter

### Use Render + Local Fallback (Recommended)
```dart
static const bool _useRender = true;  // Try Render first, fallback to local
```

### Use Local Only (Development)
```dart
static const bool _useRender = false;  // Bypass Render, use local only
```

### Change Local IP
```dart
static const String _localIp = '192.168.10.6';  // Your PC's IP on network
```

---

## 🧪 Test Commands

### Test Render URL (after deployment)
```bash
curl https://your-service-name.onrender.com/
```

Expected response:
```json
{"message":"True-Profile AI ATS Module v2.0 (Enhanced Scoring) is running!"}
```

### Test Local Server
```bash
curl http://192.168.10.6:8000/
```

Same expected response.

---

## 📐 Timeout Settings

| Server | Timeout | Why? |
|--------|---------|------|
| Render | 120 seconds | Cold start can take 60s on free tier |
| Local | 90 seconds | Processing large files + AI |

These are configured automatically in `resume_service.dart`.

---

## 🎯 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Build fails on Render | Check root directory is `backend/ats_service` |
| Service won't start | Verify start command exactly matches above |
| Flutter can't connect | Update `_renderUrl` with actual Render URL |
| Both servers fail | Check Render status + ensure `python main.py` is running locally |

---

**For full guide, see: RENDER_DEPLOY_GUIDE.md**
