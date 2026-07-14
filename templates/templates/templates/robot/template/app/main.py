import logging
from pathlib import Path

import structlog

from app.config import get_settings
from app.scheduler import run

settings = get_settings()
log_level = getattr(logging, settings.log_level.upper(), logging.INFO)

Path("logs").mkdir(exist_ok=True)
logging.basicConfig(
    level=log_level,
    format="%(message)s",
    handlers=[logging.FileHandler("logs/app.log"), logging.StreamHandler()],
)
structlog.configure(
    wrapper_class=structlog.make_filtering_bound_logger(log_level),
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.add_log_level,
        structlog.processors.JSONRenderer(),
    ],
    logger_factory=structlog.stdlib.LoggerFactory(),
)

if __name__ == "__main__":
    run()
