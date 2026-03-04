import os
import shutil
from fastapi import UploadFile, HTTPException
from uuid import uuid4

UPLOAD_DIR = "uploads/papers"
os.makedirs(UPLOAD_DIR, exist_ok=True)

async def save_upload_file(file: UploadFile, folder: str = "") -> str:
    # Validate file type
    allowed_extensions = {".pdf", ".doc", ".docx"}
    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in allowed_extensions:
        raise HTTPException(status_code=400, detail="Invalid file type. Only PDF/DOC/DOCX allowed.")

    # Generate unique filename
    filename = f"{uuid4()}{ext}"
    file_path = os.path.join(UPLOAD_DIR, folder, filename) if folder else os.path.join(UPLOAD_DIR, filename)
    os.makedirs(os.path.dirname(file_path), exist_ok=True)

    # Save file
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Return URL path (adjust for static serving)
    return f"/static/{folder}/{filename}" if folder else f"/static/{filename}"