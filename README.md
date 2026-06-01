# Acadence - College Governance System

## Overview

Acadence is a comprehensive web-based college governance system designed to digitize academic and examination processes. It replaces manual registers, paper-based approvals, and fragmented communication with a structured digital platform, enhancing transparency, accountability, and operational efficiency.

## Features

### Role-Based Access Control
- **Admin** – Manage departments, subjects, faculty assignments, and lecture scheduling
- **Faculty** – Track lectures, upload question papers, view invigilation duties, send notices
- **Student** – View academic information, lectures, and notices
- **Exam Department** – Approve question papers, manage invigilation duties, send examination notices

### Core Functionalities
- Digital lecture tracking and syllabus monitoring
- Question paper submission and multi-stage approval workflow
- Invigilation duty creation and assignment
- Real-time dashboards with role-specific KPIs
- Centralized notice system with targeted audience selection
- Secure authentication with JWT and role-based permissions

## Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter (Web) with Dart |
| Backend | FastAPI (Python) |
| Database | MongoDB |
| Authentication | JWT with bcrypt password hashing |
| File Storage | Local file system (uploads/) |
| Deployment | Local / MongoDB Atlas (optional) |

## Project Structure

```
Acadence/
├── frontend/                 # Flutter web application
│   ├── lib/
│   │   ├── auth/            # Login screen
│   │   ├── pages/           # Role-based dashboards
│   │   ├── providers/       # State management (AuthProvider)
│   │   ├── services/        # API communication layer
│   │   ├── state/           # App state (legacy)
│   │   └── theme/           # Styling and colors
│   └── pubspec.yaml
│
├── backend/                  # FastAPI backend
│   ├── app/
│   │   ├── api/endpoints/   # Route handlers (auth, admin, faculty, student, exam)
│   │   ├── core/            # Config, security, database connection
│   │   ├── models/          # Pydantic models
│   │   ├── schemas/         # Request/response schemas
│   │   └── services/        # File upload, business logic
│   ├── uploads/papers/      # Stored question papers
│   ├── requirements.txt
│   └── .env                 # Environment variables (not committed)
│
└── README.md
```

## Prerequisites

### Backend
- Python 3.10 or higher
- MongoDB (local installation or MongoDB Atlas account)
- pip package manager

### Frontend
- Flutter SDK (with web support enabled)
- Dart SDK
- Chrome or any modern browser for testing

## Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/Acadence.git
cd Acadence
```

### 2. Backend Setup

```bash
cd backend
python -m venv venv
source venv/bin/activate      # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

Create a `.env` file in the `backend/` directory:

```env
MONGO_URI=mongodb://localhost:27017/acadence
DATABASE_NAME=acadence
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

Start MongoDB locally, then run the backend:

```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`. Interactive documentation is available at `http://localhost:8000/docs`.

### 3. Frontend Setup

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

The application will open in your browser at `http://localhost:52563` (port may vary).

### 4. Create Initial Admin User

Use the Swagger UI (`http://localhost:8000/docs`) to register an admin user:

```json
{
  "email": "admin@college.edu",
  "name": "Admin User",
  "password": "admin123",
  "role": "admin",
  "department": "Administration"
}
```

Then log in through the Flutter application.

## API Endpoints Overview

| Module | Endpoints |
|--------|-----------|
| Auth | `/auth/login`, `/auth/register`, `/auth/me` |
| Admin | `/admin/stats`, `/admin/subjects`, `/admin/faculty`, `/admin/lectures` |
| Faculty | `/faculty/lectures/today`, `/faculty/question-papers`, `/faculty/notices`, `/faculty/invigilation` |
| Exam | `/exam/pending-papers`, `/exam/invigilation`, `/exam/notices` |
| Student | `/student/dashboard` |

## Key Implementation Highlights

### Authentication (JWT + bcrypt)

```python
@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = await db.db["users"].find_one({"email": form_data.username})
    if not user or not verify_password(form_data.password, user["hashed_password"]):
        raise HTTPException(status_code=401, detail="Incorrect email or password")
    access_token = create_access_token(data={"sub": str(user["_id"]), "role": user["role"]})
    return {"access_token": access_token, "token_type": "bearer"}
```

### Role-Based Access Control

```python
def require_role(required_role: str):
    def role_checker(current_user: dict = Depends(get_current_user)):
        if current_user["role"] != required_role:
            raise HTTPException(status_code=403, detail="Not enough permissions")
        return current_user
    return role_checker
```

### Flutter API Service with Token Management

```dart
class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  String? _token;

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    return await http.get(url, headers: headers);
  }
}
```

## Testing

1. **Backend** – Use Swagger UI at `http://localhost:8000/docs` to test all endpoints.
2. **Frontend** – Run `flutter test` (unit tests can be added).
3. **End-to-End** – Log in with different roles and verify that dashboards show appropriate data.

## Limitations

- Student enrollment integration is partial (lecture views based on schedule, not enrollment)
- Advanced analytics and reporting not yet implemented
- Automated email/push notifications are not integrated
- Dedicated mobile application not available (responsive web only)
- Real-time updates require page refresh (no WebSockets)

## Future Scope

- Real-time notifications via email or push
- Advanced dashboards with historical analytics
- Dedicated mobile app (iOS/Android) using Flutter
- Integration with institutional ERP/LMS systems
- Attendance tracking and grade management modules
- Multi-tenancy support for multiple institutions

## Contributors

- Simran Qureshi
- Shani Mishra

## License

This project is developed for academic purposes as part of a college governance system.

## Acknowledgments

- FastAPI and MongoDB communities for robust backend tools
- Flutter team for cross-platform UI framework
- Open-source contributors of all used packages

---

**Project Completion Date:** February 2026

**Repository:** [GitHub - Acadence](https://github.com/yourusername/Acadence)
