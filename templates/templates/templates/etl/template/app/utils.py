import time
from collections.abc import Callable
from functools import wraps

import structlog

logger = structlog.get_logger(__name__)


def timed[T](func: Callable[..., T]) -> Callable[..., T]:
    """Log how long a pipeline step took to run."""

    @wraps(func)
    def wrapper(*args: object, **kwargs: object) -> T:
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = round(time.perf_counter() - start, 3)
        logger.info("step_timing", step=func.__name__, seconds=elapsed)
        return result

    return wrapper
