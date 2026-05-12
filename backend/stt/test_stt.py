from transcriber import SpeechToText

if __name__ == "__main__":
    stt = SpeechToText(model_size="small")

    text = stt.transcribe("backend\Stt\voice-sample.wav")

    print("\n--- Transcription Result ---")
    print(text)