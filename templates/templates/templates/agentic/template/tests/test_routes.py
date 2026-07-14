from fastapi.testclient import TestClient


def test_health(client: TestClient) -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_chat(client: TestClient) -> None:
    response = client.post("/chat", json={"message": "hi"})
    assert response.status_code == 200
    assert response.json() == {"reply": "fake reply"}
