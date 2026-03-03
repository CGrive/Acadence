from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models import Timetable, Subject, User
from app.schemas import TimetableCreate, TimetableResponse
from app.core.security import get_current_user, role_required

router = APIRouter(prefix="/timetable", tags=["Timetable"])


# 🔹 Create Timetable Entry (HOD only)
@router.post("/", response_model=TimetableResponse)
def create_timetable(
    data: TimetableCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(role_required("HOD"))
):
    subject = db.query(Subject).filter(Subject.id == data.subject_id).first()
    if not subject:
        raise HTTPException(status_code=404, detail="Subject not found")

    entry = Timetable(
        subject_id=data.subject_id,
        day_of_week=data.day_of_week,
        start_time=data.start_time,
        end_time=data.end_time,
        classroom=data.classroom
    )

    db.add(entry)
    db.commit()
    db.refresh(entry)

    return entry


# 🔹 View Full Timetable
@router.get("/", response_model=List[TimetableResponse])
def get_all_timetable(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return db.query(Timetable).all()


# 🔹 View Timetable By Semester (Student use)
@router.get("/semester/{semester}", response_model=List[TimetableResponse])
def get_by_semester(
    semester: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return (
        db.query(Timetable)
        .join(Subject)
        .filter(Subject.semester == semester)
        .all()
    )


# 🔹 Cancel Lecture (HOD only)
@router.put("/{timetable_id}/cancel", response_model=TimetableResponse)
def cancel_lecture(
    timetable_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(role_required("HOD"))
):
    entry = db.query(Timetable).filter(Timetable.id == timetable_id).first()

    if not entry:
        raise HTTPException(status_code=404, detail="Not found")

    entry.is_cancelled = True
    db.commit()
    db.refresh(entry)

    return entry