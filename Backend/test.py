from fastapi import FastAPI
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

# ---------- DB SETUP ----------
DATABASE_URL = "postgresql://postgres:password@localhost/acadence"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

# ---------- MODELS ----------


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True)
    role = Column(String)  # admin / faculty / student


class Department(Base):
    __tablename__ = "departments"
    id = Column(Integer, primary_key=True)
    name = Column(String)


class Subject(Base):
    __tablename__ = "subjects"
    id = Column(Integer, primary_key=True)
    name = Column(String)
    department_id = Column(Integer, ForeignKey("departments.id"))


class Lecture(Base):
    __tablename__ = "lectures"
    id = Column(Integer, primary_key=True)
    faculty_id = Column(Integer)
    subject_id = Column(Integer)
    date = Column(DateTime, default=datetime.utcnow)


class QuestionPaper(Base):
    __tablename__ = "question_papers"
    id = Column(Integer, primary_key=True)
    subject_id = Column(Integer)
    faculty_id = Column(Integer)
    file_url = Column(String)
    status = Column(String, default="Submitted")
    timestamp = Column(DateTime, default=datetime.utcnow)


Base.metadata.create_all(bind=engine)

# ---------- APP ----------
app = FastAPI(title="Acadence – Academic Governance Backend")

# ---------- ADMIN ----------


@app.post("/admin/department")
def create_department(name: str):
    db = SessionLocal()
    db.add(Department(name=name))
    db.commit()
    return {"status": "Department created"}


@app.post("/admin/subject")
def create_subject(name: str, department_id: int):
    db = SessionLocal()
    db.add(Subject(name=name, department_id=department_id))
    db.commit()
    return {"status": "Subject created"}


@app.post("/admin/approve-paper/{paper_id}")
def approve_paper(paper_id: int):
    db = SessionLocal()
    paper = db.query(QuestionPaper).get(paper_id)
    paper.status = "Approved"
    db.commit()
    return {"status": "Question paper approved"}

# ---------- FACULTY ----------


@app.post("/faculty/lecture")
def mark_lecture(subject_id: int):
    db = SessionLocal()
    db.add(Lecture(subject_id=subject_id, faculty_id=1))
    db.commit()
    return {"status": "Lecture marked"}


@app.post("/faculty/upload-paper")
def upload_paper(subject_id: int, file_url: str):
    db = SessionLocal()
    db.add(QuestionPaper(subject_id=subject_id, faculty_id=1, file_url=file_url))
    db.commit()
    return {"status": "Question paper submitted"}

# ---------- STUDENT ----------


@app.get("/student/question-papers")
def view_approved_papers():
    db = SessionLocal()
    return db.query(QuestionPaper).filter(QuestionPaper.status == "Approved").all()

# ---------- DASHBOARD ----------


@app.get("/admin/dashboard")
def dashboard():
    db = SessionLocal()
    return {
        "departments": db.query(Department).count(),
        "subjects": db.query(Subject).count(),
        "lectures": db.query(Lecture).count(),
        "question_papers": db.query(QuestionPaper).count()
    }
