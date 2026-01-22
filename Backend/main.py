from fastapi import FastAPI
import uvicorn


app = FastAPI()


@app.get("/")
async def root():
    return {
        "Endpoints": "/test "
    }


@app.get("/test")
async def ping(name: str = "User"):
    return {"Test": f"yo {name}! It's working..."}
