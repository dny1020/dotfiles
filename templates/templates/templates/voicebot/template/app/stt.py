import io
from functools import lru_cache

from faster_whisper import WhisperModel

from app.config import get_settings


@lru_cache
def _get_model() -> WhisperModel:
    settings = get_settings()
    return WhisperModel(settings.whisper_model, device="cpu", compute_type="int8")


def transcribe(audio_bytes: bytes) -> str:
    model = _get_model()
    segments, _ = model.transcribe(io.BytesIO(audio_bytes))
    return " ".join(segment.text.strip() for segment in segments)
