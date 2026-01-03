# Use official lightweight Python image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Download necessary NLP models during build
RUN python -m spacy download en_core_web_sm
RUN python -c "import nltk; nltk.download('stopwords'); nltk.download('punkt')"

# Copy the rest of the application
COPY . .

# Expose the port (Render/Cloud Run usually set PORT env var, but we default to 8000)
ENV PORT=8000
EXPOSE 8000

# Start the application
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT}"]
