def mask_secret(value: str, visible: int = 4) -> str:
    """Mask all but the last `visible` characters, for safe logging of secrets."""
    if len(value) <= visible:
        return "*" * len(value)
    return f"{'*' * (len(value) - visible)}{value[-visible:]}"
