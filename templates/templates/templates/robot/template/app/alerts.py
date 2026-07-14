import httpx
import structlog

from app.config import get_settings

logger = structlog.get_logger(__name__)


def send_alert(message: str) -> None:
    settings = get_settings()
    if not settings.alert_webhook_url:
        logger.warning("alert_not_sent_no_webhook", message=message)
        return
    try:
        httpx.post(settings.alert_webhook_url, json={"text": message}, timeout=10)
    except httpx.HTTPError:
        logger.exception("alert_delivery_failed", message=message)
