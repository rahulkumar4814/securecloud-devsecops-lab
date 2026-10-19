"""SecureCloud Notes API - FastAPI application for the SecureCloud DevSecOps Lab."""
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field

from app import db

APP_VERSION = "0.1.0"


@asynccontextmanager
async def lifespan(_: FastAPI):
    db.init_db()  # create the table on startup
    yield


app = FastAPI(title="SecureCloud Notes API", version=APP_VERSION, lifespan=lifespan)


class NoteIn(BaseModel):
    """Input validation: reject empty titles and oversized payloads."""
    title: str = Field(min_length=1, max_length=100)
    body: str = Field(default="", max_length=2000)


class NoteOut(NoteIn):
    id: int


@app.get("/health")
def health() -> dict:
    """Liveness check used by Docker, ECS and monitoring. Reveals nothing sensitive."""
    return {"status": "ok", "version": APP_VERSION}


@app.post("/notes", response_model=NoteOut, status_code=status.HTTP_201_CREATED)
def create_note(note: NoteIn) -> dict:
    return db.create_note(note.title, note.body)


@app.get("/notes", response_model=list[NoteOut])
def list_notes() -> list[dict]:
    return db.list_notes()


@app.get("/notes/{note_id}", response_model=NoteOut)
def get_note(note_id: int) -> dict:
    note = db.get_note(note_id)
    if note is None:
        raise HTTPException(status_code=404, detail="Note not found")
    return note
