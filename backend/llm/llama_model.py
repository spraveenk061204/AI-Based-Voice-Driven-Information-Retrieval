from llama_cpp import Llama

class LocalLLM:
    def __init__(self,
                 model_path: str,
                 n_ctx: int = 4096,
                 n_threads: int = 8):

        self.llm = Llama(
            model_path=model_path,
            n_ctx=n_ctx,
            n_threads=n_threads,
            verbose=False
        )

    def generate(self, prompt: str) -> str:
        response = self.llm(
            prompt,
            max_tokens=512,
            stop=["</s>"]
        )
        return response["choices"][0]["text"].strip()