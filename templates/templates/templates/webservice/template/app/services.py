import httpx
import structlog
from fastapi import HTTPException

logger = structlog.get_logger(__name__)


class UpstreamService:
    def __init__(self, client: httpx.Client) -> None:
        self.client = client

    def get_status(self) -> dict[str, object]:
        try:
            response = self.client.get("/status")
            response.raise_for_status()
        except httpx.HTTPError as exc:
            logger.error("upstream_request_failed", error=str(exc))
            raise HTTPException(status_code=502, detail="upstream service unavailable") from exc
        return dict(response.json())
