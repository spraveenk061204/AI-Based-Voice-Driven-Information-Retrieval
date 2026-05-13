import sounddevice as sd
from scipy.io.wavfile import write
import numpy as np
from faster_whisper import WhisperModel

MODEL_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\faster-whisper"
AUDIO_PATH = "mic_input.wav"

class SpeechToText:
    def __init__(self,model_path):
        self.model=WhisperModel(
            model_path,
            device="cpu",
            compute_type="int8",
            local_files_only=True
        )
      
    

    def transcribe_audio(self,audio_path):
        print("Loading Faster‑Whisper model...")
        segments, info = self.model.transcribe(audio_path, beam_size=5)
        segments = list(segments)

        if not segments:
            return "[No speech detected]"

        text = " ".join(segment.text for segment in segments)
        print("Language: ",info.language)
        return text.strip()

"""if __name__ == "__main__":
    record_audio()
    result = transcribe_audio()

    print("\n--- Transcription Result ---")
    print(result)"""
    