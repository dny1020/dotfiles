from dataclasses import dataclass
from functools import lru_cache
from typing import Any

from langchain_core.tools import tool
from langchain_openai import ChatOpenAI
from langgraph.prebuilt import create_react_agent

from app.config import get_settings
from app.prompts import SYSTEM_PROMPT
from app.stt import transcribe
from app.tools import get_current_time
from app.tts import synthesize


@lru_cache
def get_agent() -> Any:
    settings = get_settings()
    model = ChatOpenAI(
        model=settings.llama_model,
        base_url=settings.llama_base_url,
        api_key=settings.llama_api_key,
    )
    return create_react_agent(model, tools=[tool(get_current_time)], prompt=SYSTEM_PROMPT)


@dataclass
class VoicePipeline:
    def handle(self, audio_bytes: bytes) -> tuple[str, bytes]:
        transcript = transcribe(audio_bytes)

        agent = get_agent()
        result = agent.invoke({"messages": [{"role": "user", "content": transcript}]})
        reply_text: str = result["messages"][-1].content

        reply_audio = synthesize(reply_text)
        return transcript, reply_audio


@lru_cache
def get_pipeline() -> VoicePipeline:
    return VoicePipeline()
