import pytest

from app.alerts import send_alert
from app.config import get_settings


def test_send_alert_without_webhook_does_not_raise() -> None:
    send_alert("test message")


def test_send_alert_posts_to_webhook(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[tuple[str, dict[str, str]]] = []

    def fake_post(url: str, json: dict[str, str], timeout: float) -> None:
        calls.append((url, json))

    monkeypatch.setattr("app.alerts.httpx.post", fake_post)
    monkeypatch.setattr(get_settings(), "alert_webhook_url", "http://example.com/webhook")

    send_alert("hello")

    assert calls == [("http://example.com/webhook", {"text": "hello"})]
