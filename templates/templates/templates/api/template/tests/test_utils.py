from app.utils import mask_secret


def test_mask_secret_keeps_last_characters() -> None:
    assert mask_secret("supersecret123") == "**********t123"


def test_mask_secret_short_value() -> None:
    assert mask_secret("ab") == "**"
