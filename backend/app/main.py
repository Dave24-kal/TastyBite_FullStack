from fastapi import FastAPI

app = FastAPI(title="TastyBite API")

@app.get("/")

def root():
    return{"message": "TestyBite API is running"}
 