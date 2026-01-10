# 🚀 True-Profile AI: Execution & Network Guide

This guide explains how to run the application, how to handle network changes (IP updates), and which environment files are involved.

---
# � True-Profile AI Unified Backend

I have unified all modules (ATS, Skills, and Identity Verification) into a single server. You now only need to run ONE command to start everything.

## 1. Unified Running Instructions
Open a terminal and run:
```powershell
# 1. Navigate to backend folder
cd "e:\Documents\AI\True-Profile AI\true_profile_ai\backend\ats_service"

# 2. Activate Virtual Environment
..\..\.venv\Scripts\activate

# 3. Install Unified Requirements (One-time)
pip install -r requirements.txt

# 4. Start Unified Server (ATS + Skills + Face Verification)
python main.py
```
This server will run on **Port 8000**.

## 🌐 Phase 2: Handling Network Changes (IP Updates)

If you change your Wi-Fi or move to another network, your PC's IP address will change. You MUST update this in the Flutter code, or the app will show a **Timeout Error**.

### 1. Find your current IP
In your terminal, type:
```powershell
ipconfig
```
Look for **IPv4 Address** under your active adapter (e.g., `10.69.32.169` or `192.168.10.4`).

### 2. Update the Code
Open this file:
`lib/core/constants/api_constants.dart`

Find the following line (around **Line 4**) and update it with your new IP:
```dart
static const String localIp = 'YOUR_NEW_IP_HERE'; 
```
This single change will update the ATS, Skills, and Identity modules automatically!

---

## 📱 Phase 3: Run the Flutter App

Once the backend is running and the IP is updated, start the frontend:

```powershell
# In the root directory
flutter run
```

### 💡 Troubleshooting checklist:
1. **Timeout 90s**: Means your IP is correct but the backend is taking too long to process (common for large files).
2. **Connection Refused**: Means the IP in the code is WRONG or the Python server is NOT running.
3. **Firewall**: Ensure Windows Firewall allows Python to accept connections on port `8000`.

---

**Python version used**: Python 3.x (Active in `.venv`)
**Backend Framework**: FastAPI (Uvicorn)
**Frontend Framework**: Flutter (Riverpod)
