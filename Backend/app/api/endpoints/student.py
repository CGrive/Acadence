from fastapi import APIRouter, Depends
from ...core.database import db
from ...api.deps import require_role

router = APIRouter(prefix="/student", tags=["Student"])
student_required = require_role("student")

@router.get("/dashboard")
async def get_dashboard(current_user=Depends(student_required)):
    # Get enrolled subjects, upcoming lectures, exams, notices
    # For simplicity, return dummy data structure
    return {
        "upcoming_lectures": [],
        "upcoming_exams": [],
        "syllabus_progress": 72,
        "attendance": 88.5,
        "notices": []
    }