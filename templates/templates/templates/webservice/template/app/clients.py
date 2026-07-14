from functools import lru_cache

import httpx

from app.config import get_settings


@lru_cache
def get_client() -> httpx.Client:
    settings = get_settings()
    return httpx.Client(base_url=settings.upstream_base_url, timeout=10.0)
