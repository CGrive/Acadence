from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from datetime import datetime, date
from ...core.database import db
from ...api.deps import require_role

router = APIRouter(prefix="/student", tags=["Student"])
student_required = require_role("student")

@router.get("/dashboard")
async def get_dashboard(current_user=Depends(student_required)):
    # Get today's lectures for subjects the student is enrolled in
    # For simplicity, we'll return all lectures (you can later filter by enrollment)
    today_str = date.today().isoformat()
    cursor = db.db["lectures"].find({"date": today_str})
    lectures = []
    async for doc in cursor:
        doc["id"] = str(doc.pop("_id"))
        subject = await db.db["subjects"].find_one({"_id": ObjectId(doc["subject_id"])})
        doc["subject_name"] = subject["name"] if subject else "Unknown"
        # Get faculty name
        faculty = await db.db["users"].find_one({"_id": ObjectId(doc["faculty_id"])})
        doc["faculty_name"] = faculty["name"] if faculty else "Unknown"
        lectures.append({
            "subject": doc["subject_name"],
            "faculty": doc["faculty_name"],
            "time": doc["start_time"],
            "mode": "Physical",  # placeholder, can be added to lecture model
        })

    # Get upcoming exams (could be from a separate collection)
    # Placeholder
    exams = []

    # Get notices targeted to students
    notices_cursor = db.db["notices"].find({"target": {"$in": ["students", "all"]}}).sort("timestamp", -1).limit(5)
    notices = []
    async for doc in notices_cursor:
        doc["id"] = str(doc.pop("_id"))
        notices.append({
            "title": doc["title"],
            "content": doc["content"],
            "timestamp": doc["timestamp"],
        })

    # Get syllabus progress and attendance – can be stored per student
    # Placeholder
    syllabus_progress = 72
    attendance = 88.5

    return {
        "today_lectures": lectures,
        "upcoming_exams": exams,
        "syllabus_progress": syllabus_progress,
        "attendance": attendance,
        "notices": notices,
    }