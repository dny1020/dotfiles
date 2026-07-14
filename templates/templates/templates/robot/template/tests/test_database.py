import pytest

from app.config import get_settings
from app.database import get_engine, get_session
from app.models import JobRun


def test_job_run_roundtrip(tmp_path, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("DATABASE_PATH", str(tmp_path / "test.db"))
    get_settings.cache_clear()
    get_engine.cache_clear()

    session = get_session()
    try:
        session.add(JobRun(job_name="check", success=True, detail="ok"))
        session.commit()

        rows = session.query(JobRun).all()
        assert len(rows) == 1
        assert rows[0].job_name == "check"
        assert rows[0].success is True
    finally:
        session.close()
        get_engine.cache_clear()
        get_settings.cache_clear()
