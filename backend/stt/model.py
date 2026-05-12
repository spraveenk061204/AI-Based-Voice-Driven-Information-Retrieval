from faster_whisper import WhisperModel

def test_local_model():
    MODEL_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\faster-whisper"
    AUDIO_FILE = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\backend\Stt\voice-sample.wav"

    print("***Loading local Faster-Whisper model...***")
    
    model = WhisperModel(
        MODEL_PATH,
        device="cpu",               # use "cuda" if GPU available
        compute_type="int8",
        local_files_only=True       # VERY IMPORTANT
    )

    print("Model loaded successfully ")
    print("Transcribing audio...")

    segments, info = model.transcribe(
        AUDIO_FILE,
        beam_size=5
    )

    segments = list(segments)

    if not segments:
        print("No speech detected in the audio.")
        return

    print(f"Detected language: {info.language}")
    print("\n--- Transcription Output ---")
    for segment in segments:
        print(segment.text)

if __name__ == "__main__":
    test_local_model()