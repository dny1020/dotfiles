import io
import wave
from functools import lru_cache

from piper import PiperVoice

from app.config import get_settings


@lru_cache
def _get_voice() -> PiperVoice:
    settings = get_settings()
    return PiperVoice.load(settings.piper_model_path)


def synthesize(text: str) -> bytes:
    voice = _get_voice()
    buffer = io.BytesIO()
    with wave.open(buffer, "wb") as wav_file:
        voice.synthesize_wav(text, wav_file)
    return buffer.getvalue()
