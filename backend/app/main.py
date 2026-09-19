from fastapi import FastAPI
from app.routers import auth

app = FastAPI(title="TastyBite API")
app.include_router(auth.router)

@app.get("/")

def root():
    return{"message": "TestyBite API is running"}
 