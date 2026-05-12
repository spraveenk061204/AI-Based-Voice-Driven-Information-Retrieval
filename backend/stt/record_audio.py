import sounddevice as sd
from scipy.io.wavfile import write
import numpy as np

def record_audio(
    filename="mic_input.wav",
    duration=5,
    sample_rate=16000
):
    print("🎤 Recording... Speak now")

    audio = sd.rec(
        int(duration * sample_rate),
        samplerate=sample_rate,
        channels=1,
        dtype="float32"
    )

    sd.wait()  # Wait until recording is finished
    print("✅ Recording finished")

    # Convert float32 audio to int16
    audio_int16 = np.int16(audio / np.max(np.abs(audio)) * 32767)

    write(filename, sample_rate, audio_int16)
    print(f"📁 Saved audio to {filename}")

if __name__ == "__main__":
    record_audio()