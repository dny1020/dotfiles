import pandas as pd

from app.transform import clean


def test_clean_drops_na_and_duplicates() -> None:
    df = pd.DataFrame({"a": [1, 1, None]})
    result = clean(df)
    assert len(result) == 1
