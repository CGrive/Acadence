from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import FileResponse
from bson import ObjectId
from datetime import datetime
import os
from ...core.database import db
from ...api.deps import require_role

router = APIRouter(prefix="/exam", tags=["Exam Department"])
exam_required = require_role("exam_dept")

@router.get("/pending-papers")
async def get_pending_papers(current_user=Depends(exam_required)):
    cursor = db.db["question_papers"].find({"status": "pending"}).sort("submission_date", 1)
    papers = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))
        subject = None
        if doc.get("subject_id"):
            try:
                subject = await db.db["subjects"].find_one(
                    {"_id": ObjectId(doc["subject_id"])}
                )
            except:
                pass
        doc["subject_name"] = subject["name"] if subject else "Unknown"
        faculty = None
        if doc.get("faculty_id"):
            try:
                faculty = await db.db["users"].find_one(
                    {"_id": ObjectId(doc["faculty_id"])}
                )
            except:
                pass
        doc["faculty_name"] = faculty["name"] if faculty else "Unknown"
        papers.append(doc)
    return papers

@router.post("/papers/{paper_id}/approve")
async def approve_paper(paper_id: str, current_user=Depends(exam_required)):
    try:
        obj_id = ObjectId(paper_id)
    except:
        raise HTTPException(status_code=400, detail="Invalid paper ID format")
    result = await db.db["question_papers"].update_one(
        {"_id": obj_id, "status": "pending"},
        {
            "$set": {
                "status": "approved",
                "reviewed_by": current_user.id,
                "review_date": datetime.utcnow()
            }
        }
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Paper not found or already processed")
    return {"message": "Paper approved"}

@router.post("/papers/{paper_id}/reject")
async def reject_paper(paper_id: str, current_user=Depends(exam_required)):
    try:
        obj_id = ObjectId(paper_id)
    except:
        raise HTTPException(status_code=400, detail="Invalid paper ID format")
    result = await db.db["question_papers"].update_one(
        {"_id": obj_id, "status": "pending"},
        {
            "$set": {
                "status": "rejected",
                "reviewed_by": current_user.id,
                "review_date": datetime.utcnow()
            }
        }
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Paper not found or already processed")
    return {"message": "Paper rejected"}

@router.get("/invigilation")
async def get_invigilation(current_user=Depends(exam_required)):
    cursor = db.db["invigilations"].find()
    invigilations = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))
        if doc.get("faculty_id"):
            faculty = await db.db["users"].find_one({"_id": ObjectId(doc["faculty_id"])})
            doc["faculty_name"] = faculty["name"] if faculty else "Unknown"
        invigilations.append(doc)
    return invigilations

@router.post("/invigilation")
async def create_invigilation(data: dict, current_user=Depends(exam_required)):
    required = ["exam_name", "subject", "room", "date", "start_time", "end_time"]
    for field in required:
        if field not in data:
            raise HTTPException(status_code=400, detail=f"Missing field: {field}")
    data["faculty_id"] = None
    data["status"] = "unassigned"
    result = await db.db["invigilations"].insert_one(data)
    return {"id": str(result.inserted_id), "message": "Invigilation created"}

@router.post("/invigilation/{invigilation_id}/assign")
async def assign_invigilation(
    invigilation_id: str,
    data: dict,
    current_user=Depends(exam_required)
):
    faculty_id = data.get("faculty_id")
    if not faculty_id:
        raise HTTPException(status_code=400, detail="faculty_id is required")
    try:
        obj_id = ObjectId(invigilation_id)
        faculty_obj_id = ObjectId(faculty_id)
    except:
        raise HTTPException(status_code=400, detail="Invalid ID format")
    result = await db.db["invigilations"].update_one(
        {"_id": obj_id},
        {"$set": {"faculty_id": faculty_id, "status": "assigned"}}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Invigilation not found")
    return {"message": "Assigned successfully"}

@router.get("/faculty")
async def get_faculty_list(current_user=Depends(exam_required)):
    cursor = db.db["users"].find({"role": "faculty"})
    faculty = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))
        faculty.append(doc)
    return faculty

@router.get("/notices")
async def get_notices(current_user=Depends(exam_required)):
    cursor = db.db["notices"].find().sort("timestamp", -1).limit(20)
    notices = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))
        notices.append(doc)
    return notices

@router.post("/notices")
async def create_notice(notice: dict, current_user=Depends(exam_required)):
    notice["sender_id"] = current_user.id
    notice["timestamp"] = datetime.utcnow()
    result = await db.db["notices"].insert_one(notice)
    return {"id": str(result.inserted_id), "message": "Notice sent"}

@router.get("/download-paper/{paper_id}")
async def download_paper(paper_id: str, current_user=Depends(exam_required)):
    try:
        obj_id = ObjectId(paper_id)
    except:
        raise HTTPException(status_code=400, detail="Invalid paper ID")
    paper = await db.db["question_papers"].find_one({"_id": obj_id})
    if not paper:
        raise HTTPException(status_code=404, detail="Paper not found")
    file_url = paper.get("file_url")
    if not file_url:
        raise HTTPException(status_code=404, detail="File not found")

    print(f"file_url from DB: {file_url}")
    relative_path = file_url.replace("/static/", "")  # e.g., "papers/e6478dd6-....pdf"
    print(f"relative_path: {relative_path}")

    filename = os.path.basename(relative_path)

    # Try multiple possible base directories, including the nested "papers" folder
    possible_paths = [
        os.path.join("uploads", relative_path),                                    # uploads/papers/filename.pdf
        os.path.join(os.getcwd(), "uploads", relative_path),                      # absolute
        os.path.join(os.path.dirname(__file__), "../../uploads", relative_path),  # relative to this file
        os.path.join("uploads", "papers", relative_path),                         # uploads/papers/papers/filename.pdf
        os.path.join(os.getcwd(), "uploads", "papers", relative_path),            # absolute with extra papers
    ]

    file_path = None
    for path in possible_paths:
        normalized = os.path.normpath(path)
        print(f"Checking path: {normalized}")
        if os.path.exists(normalized):
            file_path = normalized
            print(f"File found at: {normalized}")
            break

    if not file_path:
        print(f"File not found. Current working directory: {os.getcwd()}")
        # List directory contents for debugging
        uploads_dir = os.path.join(os.getcwd(), "uploads")
        if os.path.exists(uploads_dir):
            print(f"Uploads directory contents: {os.listdir(uploads_dir)}")
            papers_dir = os.path.join(uploads_dir, "papers")
            if os.path.exists(papers_dir):
                print(f"Papers directory contents: {os.listdir(papers_dir)}")
                nested_papers_dir = os.path.join(papers_dir, "papers")
                if os.path.exists(nested_papers_dir):
                    print(f"Nested papers directory contents: {os.listdir(nested_papers_dir)}")
        raise HTTPException(status_code=404, detail="File not found on disk")

    return FileResponse(
        path=file_path,
        filename=filename,
        media_type="application/octet-stream",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )