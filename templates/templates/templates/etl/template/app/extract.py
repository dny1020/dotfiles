import io

import httpx
import pandas as pd

from app.config import get_settings
from app.utils import timed


@timed
def fetch() -> pd.DataFrame:
    settings = get_settings()
    response = httpx.get(settings.source_url, timeout=30)
    response.raise_for_status()
    return pd.read_csv(io.StringIO(response.text))
