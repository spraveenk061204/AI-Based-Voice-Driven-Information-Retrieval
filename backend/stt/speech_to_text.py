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
      
    def record_audio(self,duration=10, sample_rate=16000):
        print("Recording... Speak your question")

        audio = sd.rec(
            int(duration * sample_rate),
            samplerate=sample_rate,
            channels=1,
            dtype="float32"
        )
        sd.wait()
        print("Recording finished")

        audio_int16 = np.int16(audio / np.max(np.abs(audio)) * 32767)
        write(AUDIO_PATH, sample_rate, audio_int16)

    def transcribe_audio(self,audio_path=AUDIO_PATH):
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
    