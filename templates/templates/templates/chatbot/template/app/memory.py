from collections import defaultdict
from functools import lru_cache

Message = dict[str, str]


class ConversationMemory:
    """In-memory conversation history, keyed by session_id.

    Not persisted across restarts. Swap for Redis/DB storage if you need that.
    """

    def __init__(self, max_messages: int = 20) -> None:
        self._history: dict[str, list[Message]] = defaultdict(list)
        self.max_messages = max_messages

    def get(self, session_id: str) -> list[Message]:
        return self._history[session_id]

    def add(self, session_id: str, role: str, content: str) -> None:
        history = self._history[session_id]
        history.append({"role": role, "content": content})
        if len(history) > self.max_messages:
            del history[: len(history) - self.max_messages]


@lru_cache
def get_memory() -> ConversationMemory:
    return ConversationMemory()
