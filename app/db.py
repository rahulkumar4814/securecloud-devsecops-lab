"""SQLite data access for the SecureCloud Notes API.

Security note: every query uses parameter placeholders (?) so user input is
never concatenated into SQL. (Sprint 3 deliberately breaks this in a lab
branch to show how Semgrep catches SQL injection.)
"""
import os
import sqlite3
from contextlib import contextmanager


def db_path() -> str:
    """Database file location; overridable for tests and containers."""
    return os.environ.get("NOTES_DB_PATH", "notes.db")


@contextmanager
def get_conn():
    conn = sqlite3.connect(db_path())
    conn.row_factory = sqlite3.Row
    try:
        yield conn
        conn.commit()
    finally:
        conn.close()


def init_db() -> None:
    with get_conn() as conn:
        conn.execute(
            "CREATE TABLE IF NOT EXISTS notes ("
            " id INTEGER PRIMARY KEY AUTOINCREMENT,"
            " title TEXT NOT NULL,"
            " body TEXT NOT NULL DEFAULT ''"
            ")"
        )


def create_note(title: str, body: str) -> dict:
    with get_conn() as conn:
        cur = conn.execute(
            "INSERT INTO notes (title, body) VALUES (?, ?)", (title, body)
        )
        return {"id": cur.lastrowid, "title": title, "body": body}


def list_notes() -> list[dict]:
    with get_conn() as conn:
        rows = conn.execute("SELECT id, title, body FROM notes ORDER BY id").fetchall()
        return [dict(r) for r in rows]


def get_note(note_id: int) -> dict | None:
    with get_conn() as conn:
        row = conn.execute(
            "SELECT id, title, body FROM notes WHERE id = ?", (note_id,)
        ).fetchone()
        return dict(row) if row else None
