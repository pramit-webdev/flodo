import asyncio
import os
from datetime import datetime
from typing import List, Optional
from uuid import UUID

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from supabase import create_client, Client

load_dotenv()

app = FastAPI(title="Flodo Task Manager API")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# Supabase configuration
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("Warning: SUPABASE_URL or SUPABASE_KEY not set. API will be limited.")
    supabase: Optional[Client] = None
else:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Models
class TaskBase(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    due_date: Optional[datetime] = None
    status: Optional[str] = None
    blocked_by_id: Optional[UUID] = None
    order_index: Optional[int] = 0

class TaskCreate(TaskBase):
    title: str
    description: str
    due_date: datetime
    status: str

class TaskUpdate(TaskBase):
    pass

class Task(TaskBase):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True

# Helper to simulate delay
async def simulate_delay():
    await asyncio.sleep(2)

@app.get("/tasks", response_model=List[Task])
async def get_tasks(
    status: Optional[str] = None,
    search: Optional[str] = None
):
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase not configured")
    
    query = supabase.table("tasks").select("*").order("order_index")
    
    if status:
        query = query.eq("status", status)
    
    if search:
        query = query.ilike("title", f"%{search}%")
    
    result = query.execute()
    return result.data

@app.post("/tasks", response_model=Task)
async def create_task(task: TaskCreate):
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase not configured")
    
    await simulate_delay()
    
    data = task.model_dump()
    # Convert UUID to string for Supabase
    if data.get("blocked_by_id"):
        data["blocked_by_id"] = str(data["blocked_by_id"])
    
    result = supabase.table("tasks").insert(data).execute()
    
    if not result.data:
        raise HTTPException(status_code=400, detail="Failed to create task")
    
    return result.data[0]

@app.put("/tasks/{task_id}", response_model=Task)
async def update_task(task_id: UUID, task: TaskUpdate):
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase not configured")
    
    await simulate_delay()
    
    data = {k: v for k, v in task.model_dump().items() if v is not None}
    if data.get("blocked_by_id"):
        data["blocked_by_id"] = str(data["blocked_by_id"])
    
    result = supabase.table("tasks").update(data).eq("id", str(task_id)).execute()
    
    if not result.data:
        raise HTTPException(status_code=404, detail="Task not found")
    
    return result.data[0]

@app.delete("/tasks/{task_id}")
async def delete_task(task_id: UUID):
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase not configured")
    
    result = supabase.table("tasks").delete().eq("id", str(task_id)).execute()
    
    if not result.data:
        raise HTTPException(status_code=404, detail="Task not found")
    
    return {"message": "Task deleted successfully"}

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
