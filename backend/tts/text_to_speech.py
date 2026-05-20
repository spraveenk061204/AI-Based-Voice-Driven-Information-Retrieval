import torch
from transformers import AutoProcessor, BarkModel
from scipy.io.wavfile import write

torch.set_grad_enabled(False)
torch.set_num_threads(4)
SPEAKER_PRESET = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\models\bark-small\speaker_embeddings\v2\en_speaker_6_semantic_prompt.npy"
class TextToSpeech:
    def __init__(self, model_path):
        self.processor = AutoProcessor.from_pretrained(
            model_path, local_files_only=True
        )
        self.model = BarkModel.from_pretrained(
            model_path, local_files_only=True
        )
        self.sample_rate = self.model.generation_config.sample_rate

    def synthesize(self, text, output_path):
        inputs = self.processor(text,voice_preset = "v2/en_speaker_6", return_tensors="pt")

        with torch.no_grad():
            audio = self.model.generate(
                **inputs,
                do_sample=True,
                semantic_temperature=0.6,
                coarse_temperature=0.6,
                fine_temperature=0.6,
            )

        write(
            output_path,
            self.model.generation_config.sample_rate,
            audio.cpu().numpy().squeeze()
        )
        return output_path