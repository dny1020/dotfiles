import structlog
from apscheduler.schedulers.blocking import BlockingScheduler

from app.config import get_settings
from app.jobs import run_check_job

logger = structlog.get_logger(__name__)


def build_scheduler() -> BlockingScheduler:
    settings = get_settings()
    scheduler = BlockingScheduler()
    scheduler.add_job(run_check_job, "interval", minutes=settings.interval_minutes, id="check")
    return scheduler


def run() -> None:
    settings = get_settings()
    logger.info("scheduler_start", interval_minutes=settings.interval_minutes)
    build_scheduler().start()
