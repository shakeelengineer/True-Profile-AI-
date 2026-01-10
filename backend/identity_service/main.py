import cv2
import numpy as np
from fastapi import FastAPI, UploadFile, File, HTTPException
from insightface.app import FaceAnalysis
import insightface
from scipy.spatial.distance import cosine
from typing import List
import io

app = FastAPI(title="Identity Verification Service")

# Initialize FaceAnalysis with Buffalo_L model (includes detection and recognition)
# We use only detection and recognition for face verification
face_analyzer = FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])
face_analyzer.prepare(ctx_id=0, det_size=(640, 640))

def get_embedding(image_bytes):
    """
    Decodes image bytes, detects face, and returns the embedding of the largest face.
    """
    # Convert bytes to numpy array
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    if img is None:
        raise HTTPException(status_code=400, detail="Could not decode image.")

    # Detect faces
    faces = face_analyzer.get(img)
    
    if not faces:
        return None
    
    # Return embedding of the largest face (assuming the main subject)
    # faces are already sorted or we can find the one with largest bbox
    best_face = max(faces, key=lambda x: (x.bbox[2]-x.bbox[0]) * (x.bbox[3]-x.bbox[1]))
    return best_face.normed_embedding

@app.post("/verify-face")
async def verify_face(
    selfie: UploadFile = File(...),
    references: List[UploadFile] = File(...)
):
    """
    Endpoint to verify a live selfie against a set of reference images.
    Returns verified status and confidence score.
    """
    try:
        # Get selfie embedding
        selfie_bytes = await selfie.read()
        selfie_embedding = get_embedding(selfie_bytes)
        
        if selfie_embedding is None:
            return {"verified": False, "error": "No face detected in selfie image."}

        best_score = 0.0
        
        # Compare with each reference image
        for ref_file in references:
            ref_bytes = await ref_file.read()
            ref_embedding = get_embedding(ref_bytes)
            
            if ref_embedding is not None:
                # Calculate cosine similarity
                # similarity = 1 - cosine_distance
                # InsightFace normed_embeddings allow simple dot product for similarity
                score = np.dot(selfie_embedding, ref_embedding)
                if score > best_score:
                    best_score = score

        # Threshold check (0.75 as requested)
        verified = float(best_score) >= 0.75
        
        return {
            "verified": verified,
            "confidence": float(best_score) if best_score > 0 else 0.0
        }

    except Exception as e:
        print(f"Error during verification: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
