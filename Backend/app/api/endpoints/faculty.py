from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from bson import ObjectId  # <-- IMPORT ADDED
from datetime import datetime
from ...core.database import db
from ...models.question_paper import QuestionPaper, PaperStatus
from ...schemas.question_paper import QuestionPaperCreate, QuestionPaperOut
from ...api.deps import require_role
from ...services.file_upload import save_upload_file

router = APIRouter(prefix="/faculty", tags=["Faculty"])
faculty_required = require_role("faculty")

@router.get("/lectures/today")
async def get_today_lectures(current_user=Depends(faculty_required)):
    print(f"Current user ID: {current_user.id}")
    cursor = db.db["lectures"].find({"faculty_id": current_user.id})
    lectures = []
    async for doc in cursor:
        print(f"Found lecture: {doc}")
        doc["id"] = str(doc.pop("_id"))
        subject = await db.db["subjects"].find_one({"_id": ObjectId(doc["subject_id"])})
        doc["subject_name"] = subject["name"] if subject else "Unknown"
        lectures.append(doc)
    print(f"Returning {len(lectures)} lectures")
    return lectures
    
@router.post("/lectures/{lecture_id}/conduct")
async def mark_lecture_conducted(lecture_id: str, current_user=Depends(faculty_required)):
    try:
        obj_id = ObjectId(lecture_id)
    except:
        raise HTTPException(status_code=400, detail="Invalid lecture ID format")
    
    result = await db.db["lectures"].update_one(
        {"_id": obj_id, "faculty_id": current_user.id},
        {"$set": {"conducted": True}}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Lecture not found or already conducted")
    return {"message": "Lecture marked as conducted"}

@router.get("/grading-queue")
async def get_grading_queue(current_user=Depends(faculty_required)):
    # Placeholder – implement later
    return []

@router.post("/question-papers", response_model=QuestionPaperOut)
async def upload_question_paper(
    subject_id: str = Form(...),
    exam_type: str = Form(...),
    file: UploadFile = File(...),
    current_user=Depends(faculty_required)
):
    # Save file
    file_url = await save_upload_file(file, folder="papers")
    paper = QuestionPaper(
        subject_id=subject_id,
        faculty_id=current_user.id,
        exam_type=exam_type,
        file_url=file_url,
        status=PaperStatus.pending
    )
    result = await db.db["question_papers"].insert_one(paper.dict())
    created = await db.db["question_papers"].find_one({"_id": result.inserted_id})
    created["id"] = str(created.pop("_id"))  # Convert _id to id
    return created

@router.get("/question-papers", response_model=list[QuestionPaperOut])
async def get_my_papers(current_user=Depends(faculty_required)):
    cursor = db.db["question_papers"].find({"faculty_id": current_user.id}).sort("submission_date", -1)
    papers = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))
        subject_name = "Unknown"
        # Safely look up subject name
        if doc.get("subject_id"):
            try:
                obj_id = ObjectId(doc["subject_id"])
                subject = await db.db["subjects"].find_one({"_id": obj_id})
                if subject:
                    subject_name = subject.get("name", "Unknown")
            except:
                pass  # leave as Unknown
        doc["subject_name"] = subject_name
        papers.append(doc)
    return papers

@router.post("/notices")
async def send_notice(notice_data: dict, current_user=Depends(faculty_required)):
    notice = {
        **notice_data,
        "sender_id": current_user.id,
        "timestamp": datetime.utcnow()
    }
    result = await db.db["notices"].insert_one(notice)
    return {"id": str(result.inserted_id), "message": "Notice sent"}

@router.get("/subjects")
async def get_faculty_subjects(current_user=Depends(faculty_required)):
    # For now, return all subjects. Later you can filter by faculty_id.
    cursor = db.db["subjects"].find()
    subjects = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))
        subjects.append(doc)
    return subjects

@router.get("/grading-queue")
async def get_grading_queue(current_user=Depends(faculty_required)):
    # Placeholder – replace with actual database query later
    return [
        {
            "id": "1",
            "subject": "Advanced Algorithms",
            "assignment": "Mid-Term Exam",
            "submissions": 42,
            "deadline": "2026-03-10"
        },
        {
            "id": "2",
            "subject": "Operating Systems",
            "assignment": "Final Quiz",
            "submissions": 35,
            "deadline": "2026-03-12"
        }
    ]

@router.get("/invigilation")
async def get_my_invigilation(current_user=Depends(faculty_required)):
    cursor = db.db["invigilations"].find({"faculty_id": current_user.id})
    invigilations = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))
        invigilations.append(doc)
    return invigilations