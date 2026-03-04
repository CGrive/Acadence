from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId, errors 
from ...core.database import db
from ...models.subject import Subject
from ...schemas.subject import SubjectCreate, SubjectOut
from ...api.deps import require_role

router = APIRouter(prefix="/admin", tags=["Admin"])
admin_required = require_role("admin")

@router.get("/stats")
async def get_stats(current_user=Depends(admin_required)):
    total_departments = await db.db["subjects"].distinct("department")
    active_subjects = await db.db["subjects"].count_documents({})
    from datetime import date
    today = date.today().isoformat()
    daily_lectures = await db.db["lectures"].count_documents({"date": today})
    total_papers = await db.db["question_papers"].count_documents({})
    approved = await db.db["question_papers"].count_documents({"status": "approved"})
    return {
        "total_departments": len(total_departments),
        "active_subjects": active_subjects,
        "daily_lectures": daily_lectures,
        "approved_papers": approved,
        "total_papers": total_papers
    }

@router.get("/recent-submissions")
async def recent_submissions(limit: int = 10, current_user=Depends(admin_required)):
    cursor = db.db["question_papers"].find().sort("submission_date", -1).limit(limit)
    papers = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))
        subject_name = "Unknown"
        faculty_name = "Unknown"

        # Safely look up subject name
        if doc.get("subject_id"):
            try:
                obj_id = ObjectId(doc["subject_id"])
                subject = await db.db["subjects"].find_one({"_id": obj_id})
                if subject:
                    subject_name = subject.get("name", "Unknown")
            except:
                pass  # leave as Unknown

        # Safely look up faculty name
        if doc.get("faculty_id"):
            try:
                obj_id = ObjectId(doc["faculty_id"])
                faculty = await db.db["users"].find_one({"_id": obj_id})
                if faculty:
                    faculty_name = faculty.get("name", "Unknown")
            except:
                pass

        papers.append({
            "id": doc["id"],
            "subject_name": subject_name,
            "faculty_name": faculty_name,
            "date": doc["submission_date"],
            "status": doc["status"]
        })
    return papers

@router.post("/subjects", response_model=SubjectOut)
async def create_subject(subject: SubjectCreate, current_user=Depends(admin_required)):
    subject_dict = subject.dict()
    result = await db.db["subjects"].insert_one(subject_dict)
    created = await db.db["subjects"].find_one({"_id": result.inserted_id})
    created["id"] = str(created.pop("_id"))  # Convert _id to id
    return created

@router.get("/subjects", response_model=list[SubjectOut])
async def list_subjects(current_user=Depends(admin_required)):
    cursor = db.db["subjects"].find()
    subjects = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))  # Convert _id to id and remove
        subjects.append(doc)
    return subjects

@router.get("/faculty")
async def list_faculty(current_user=Depends(admin_required)):
    cursor = db.db["users"].find({"role": "faculty"})
    faculty = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))
        faculty.append(doc)
    return faculty

@router.put("/subjects/{subject_id}")
async def update_subject(subject_id: str, subject: SubjectCreate, current_user=Depends(admin_required)):
    try:
        obj_id = ObjectId(subject_id)
    except:
        raise HTTPException(status_code=400, detail="Invalid subject ID")
    
    result = await db.db["subjects"].update_one(
        {"_id": obj_id},
        {"$set": subject.dict()}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Subject not found")
    
    updated = await db.db["subjects"].find_one({"_id": obj_id})
    updated["id"] = str(updated.pop("_id"))
    return updated

from ...models.lecture import Lecture
from ...schemas.lecture import LectureCreate, LectureOut

@router.post("/lectures", response_model=LectureOut)
async def create_lecture(lecture: LectureCreate, current_user=Depends(admin_required)):
    lecture_dict = lecture.dict()
    # No conversion needed – the frontend already sends strings
    result = await db.db["lectures"].insert_one(lecture_dict)
    created = await db.db["lectures"].find_one({"_id": result.inserted_id})
    created["id"] = str(created.pop("_id"))
    return created

from ...models.lecture import Lecture
from ...schemas.lecture import LectureCreate, LectureOut

@router.post("/lectures", response_model=LectureOut)
async def create_lecture(lecture: LectureCreate, current_user=Depends(admin_required)):
    lecture_dict = lecture.dict()
    result = await db.db["lectures"].insert_one(lecture_dict)
    created = await db.db["lectures"].find_one({"_id": result.inserted_id})
    created["id"] = str(created.pop("_id"))
    return created

@router.get("/lectures", response_model=list[LectureOut])
async def list_lectures(current_user=Depends(admin_required)):
    cursor = db.db["lectures"].find().sort("date", -1)
    lectures = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))
        lectures.append(doc)
    return lectures
