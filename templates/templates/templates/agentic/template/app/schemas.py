from pydantic import BaseModel


class HealthResponse(BaseModel):
    status: str = "ok"


class ChatRequest(BaseModel):
    message: str


class ChatResponse(BaseModel):
    reply: str
