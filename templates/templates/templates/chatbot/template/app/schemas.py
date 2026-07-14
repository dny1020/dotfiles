from pydantic import BaseModel


class HealthResponse(BaseModel):
    status: str = "ok"


class ChatRequest(BaseModel):
    session_id: str
    message: str


class ChatResponse(BaseModel):
    reply: str
