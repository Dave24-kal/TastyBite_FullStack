from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import auth, foods, orders, dashboard

app = FastAPI(title="TastyBite API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(foods.router)
app.include_router(orders.router)
app.include_router(dashboard.router)


@app.get("/")
def root():
    return {"message": "TastyBite API is running"}