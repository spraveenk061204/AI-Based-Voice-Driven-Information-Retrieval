from faster_whisper import WhisperModel


class SpeechToText:
    def __init__(self,
                 model_size: str = "small",
                 device: str = "cpu"):
        """
        Initialize Faster-Whisper STT model.

        model_size: tiny | base | small | medium | large
        device: cpu | cuda
        """
        self.model = WhisperModel(
           r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\faster-whisper",
            device=device,
            compute_type="int8",  # optimized for CPU
            local_files_only=True
        )

    def transcribe(self, audio_path: str) -> str:
        """
        Transcribes a WAV audio file into text.
        """
        segments, info = self.model.transcribe(
            audio_path,
            beam_size=5
        )

        transcription = []
        for segment in segments:
            transcription.append(segment.text)

        return " ".join(transcription).strip()