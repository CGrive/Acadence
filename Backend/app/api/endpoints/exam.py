from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId  
from datetime import datetime
from ...core.database import db
from ...api.deps import require_role

router = APIRouter(prefix="/exam", tags=["Exam Department"])
exam_required = require_role("exam_dept")

@router.get("/pending-papers")
async def get_pending_papers(current_user=Depends(exam_required)):
    cursor = db.db["question_papers"].find({"status": "pending"}).sort("submission_date", 1)
    papers = []
    async for doc in cursor:
        # Convert _id to string id
        doc["id"] = str(doc.pop("_id"))
        
        # Fetch subject name (convert subject_id string to ObjectId)
        subject = None
        if doc.get("subject_id"):
            try:
                subject = await db.db["subjects"].find_one(
                    {"_id": ObjectId(doc["subject_id"])}
                )
            except:
                pass
        doc["subject_name"] = subject["name"] if subject else "Unknown"
        
        # Fetch faculty name
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
    inv = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))
        inv.append(doc)
    return inv