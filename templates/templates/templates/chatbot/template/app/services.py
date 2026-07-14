from typing import Any

from app.memory import ConversationMemory


def handle_message(agent: Any, memory: ConversationMemory, session_id: str, text: str) -> str:
    memory.add(session_id, "user", text)
    history = memory.get(session_id)

    result = agent.invoke({"messages": history})
    reply: str = result["messages"][-1].content

    memory.add(session_id, "assistant", reply)
    return reply
