from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import os

from llm.llama_model import LocalLLM
from llm.rag_prompt import build_rag_prompt
from rag.rag_pipeline import RAGpipeline
from stt.speech_to_text import SpeechToText

# ---------------- CONFIG ----------------
PDF_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\backend\data\user_manual.pdf"
STT_MODEL_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\faster-whisper"
LLM_MODEL_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\mistral\mistral-7b-instruct-v0.2.Q4_K_M.gguf"

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# ---------------- APP ----------------
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------- LOAD MODELS ONCE ----------------
stt = SpeechToText(STT_MODEL_PATH)
rag = RAGpipeline(PDF_PATH)
llm = LocalLLM(model_path=LLM_MODEL_PATH)

# ---------------- ENDPOINT ----------------
@app.post("/ask")
async def ask(file: UploadFile = File(...)):
    # Save uploaded audio
    audio_path = os.path.join(UPLOAD_DIR, file.filename)
    with open(audio_path, "wb") as f:
        f.write(await file.read())

    # STT
    query_text = stt.transcribe_audio(audio_path)

    # RAG
    retrieved_data = rag.retrieve(query_text)
    prompt = build_rag_prompt(retrieved_data, query_text)

    # LLM
    answer = llm.generate(prompt)

    return {
        "question": query_text,
        "answer": answer
    }