from datetime import UTC, datetime


def get_current_time() -> str:
    """Return the current UTC time in ISO format."""
    return datetime.now(UTC).isoformat()
