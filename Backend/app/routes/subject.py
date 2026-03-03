from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models import Subject, User
from app.schemas import (
    SubjectCreate,
    SubjectResponse,
    SubjectAssignProfessor
)
from app.core.security import get_current_user, role_required

router = APIRouter(prefix="/subjects", tags=["Subjects"])


# 🔹 Create Subject (HOD/Admin only)
@router.post("/", response_model=SubjectResponse)
def create_subject(
    subject: SubjectCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(role_required("HOD"))
):
    new_subject = Subject(
        name=subject.name,
        semester=subject.semester,
        department=subject.department
    )

    db.add(new_subject)
    db.commit()
    db.refresh(new_subject)

    return new_subject


# 🔹 View All Subjects (Any logged in user)
@router.get("/", response_model=List[SubjectResponse])
def get_subjects(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return db.query(Subject).all()


# 🔹 Assign Professor (HOD/Admin only)
@router.put("/{subject_id}/assign", response_model=SubjectResponse)
def assign_professor(
    subject_id: int,
    data: SubjectAssignProfessor,
    db: Session = Depends(get_db),
    current_user: User = Depends(role_required("HOD"))
):
    subject = db.query(Subject).filter(Subject.id == subject_id).first()

    if not subject:
        raise HTTPException(status_code=404, detail="Subject not found")

    professor = db.query(User).filter(
        User.id == data.professor_id,
        User.role == "Professor"
    ).first()

    if not professor:
        raise HTTPException(status_code=400, detail="Invalid Professor ID")

    subject.assigned_professor_id = professor.id

    db.commit()
    db.refresh(subject)

    return subject