import time
from collections.abc import Callable
from functools import wraps

import structlog

logger = structlog.get_logger(__name__)


def retry[T](func: Callable[..., T]) -> Callable[..., T]:
    """Retry a function up to 3 times with a short delay, logging each failure."""
    attempts = 3
    delay_seconds = 2.0

    @wraps(func)
    def wrapper(*args: object, **kwargs: object) -> T:
        last_exc: Exception | None = None
        for attempt in range(1, attempts + 1):
            try:
                return func(*args, **kwargs)
            except Exception as exc:
                last_exc = exc
                logger.warning("retry_attempt_failed", attempt=attempt, error=str(exc))
                if attempt < attempts:
                    time.sleep(delay_seconds)
        assert last_exc is not None
        raise last_exc

    return wrapper
