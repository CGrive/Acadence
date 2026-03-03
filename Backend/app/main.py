from fastapi import FastAPI
from app.database import engine, Base
from app.routes import auth, subject, timetable
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Acadence Backend")

app.include_router(auth.router)
app.include_router(subject.router)
app.include_router(timetable.router)