# 🚀 True-Profile AI: Execution & Network Guide

This guide explains how to run the application, how to handle network changes (IP updates), and which environment files are involved.

---

## 🛠️ Phase 1: Start the Backend (Python)

The backend must be running for **JustScreen AI** (Resume Analysis) to work.

### 1. Environment Details
- **Python Environment**: Uses the virtual environment located at the root: `.venv/`
- **Script Location**: `backend/ats_service/main.py`
- **Default Port**: `8000`

### 2. How to Run
Open a terminal and run:
```powershell
# 1. Navigate to backend folder
cd "e:\Documents\AI\True-Profile AI\true_profile_ai\backend\ats_service"

# 2. Activate Virtual Environment
..\..\.venv\Scripts\activate

# 3. Start Server
python main.py
```

---

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
`lib/features/resume/services/resume_service.dart`

Find the following line (around **Line 32**) and update it with your new IP:
```dart
// Update this string with the IP from ipconfig
String baseUrl = 'YOUR_NEW_IP_HERE'; 
```

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
