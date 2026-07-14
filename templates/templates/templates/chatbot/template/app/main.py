import logging
from pathlib import Path

import structlog
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from app.config import get_settings
from app.routes import public_router, router

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
logger = structlog.get_logger(__name__)

app = FastAPI(title=settings.app_name)
app.include_router(public_router)
app.include_router(router)


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    logger.error("unhandled_exception", path=request.url.path, error=str(exc))
    return JSONResponse(status_code=500, content={"detail": "internal server error"})
