from functools import lru_cache
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.config import get_settings
from app.models import Base


@lru_cache
def get_engine() -> Engine:
    settings = get_settings()
    Path(settings.database_path).parent.mkdir(parents=True, exist_ok=True)
    engine = create_engine(f"sqlite:///{settings.database_path}")
    Base.metadata.create_all(engine)
    return engine


def get_session() -> Session:
    session_factory = sessionmaker(bind=get_engine())
    return session_factory()
