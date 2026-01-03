# Deployment Guide for True-Profile AI ATS Backend

To solve the issue of changing IP addresses and allow multiple users to access the app, you must **deploy** the Python backend to a cloud server. This provides a permanent, public URL (e.g., `https://your-app.onrender.com`) that never changes.

## Recommended Free/Cheap Options

### Option 1: Render (Easiest)
1.  Push your code to GitHub.
2.  Sign up at [render.com](https://render.com).
3.  Click **New +** -> **Web Service**.
4.  Connect your GitHub repo.
5.  Select the `backend/ats_service` directory as the Root Directory (if asked).
6.  **Runtime**: Docker
7.  Click **Create Web Service**.
8.  Render will give you a URL (e.g., `https://true-profile-ats.onrender.com`).
9.  **Update your Flutter App**: Replace `http://192.168.x.x:8000` with this new URL.

### Option 2: Fly.io (Command Line)
1.  Install flyctl.
2.  Navigate to `backend/ats_service`.
3.  Run `fly launch`.
4.  Follow the prompts.

## Why this is "Best Practice"
-   **Static URL**: The URL never changes, even if you move your laptop.
-   **Accessibility**: Users on 4G, different WiFi, or anywhere in the world can access it.
-   **Reliability**: The server runs 24/7 in the cloud, not dependent on your laptop being on.

## For Local Development (If you still want to run locally)
If you are strictly testing alone and don't want to deploy yet, there is no magic fix for IPs changing. That is how local networking works. However, you can use **ngrok**:
1.  Run backend: `python main.py`
2.  Run ngrok: `ngrok http 8000`
3.  Copy the `https://....ngrok-free.app` URL.
4.  Paste it into `resume_service.dart`.
This URL works from any network but changes every time you restart ngrok (unless you pay).
