from app.scheduler import build_scheduler


def test_build_scheduler_registers_check_job() -> None:
    scheduler = build_scheduler()
    job_ids = [job.id for job in scheduler.get_jobs()]
    assert "check" in job_ids
