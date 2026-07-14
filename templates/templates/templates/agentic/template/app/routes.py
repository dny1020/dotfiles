from typing import Any

from fastapi import APIRouter, Depends

from app.ai import get_agent
from app.schemas import ChatRequest, ChatResponse, HealthResponse

router = APIRouter()


@router.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    return HealthResponse()


@router.post("/chat", response_model=ChatResponse)
def chat(data: ChatRequest, agent: Any = Depends(get_agent)) -> ChatResponse:
    result = agent.invoke({"messages": [{"role": "user", "content": data.message}]})
    reply = result["messages"][-1].content
    return ChatResponse(reply=reply)
