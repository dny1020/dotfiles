from collections.abc import Generator
from types import SimpleNamespace
from typing import Any

import pytest
from fastapi.testclient import TestClient

from app.ai import get_agent
from app.main import app


class FakeAgent:
    def invoke(self, state: dict[str, Any]) -> dict[str, Any]:
        return {"messages": [SimpleNamespace(content="fake reply")]}


@pytest.fixture()
def client() -> Generator[TestClient]:
    app.dependency_overrides[get_agent] = lambda: FakeAgent()
    yield TestClient(app)
    app.dependency_overrides.clear()
