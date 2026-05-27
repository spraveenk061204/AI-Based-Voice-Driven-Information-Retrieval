from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse, JSONResponse
import uuid
import shutil
import os
from fastapi import Request

from llm.llama_model import LocalLLM
from rag.rag_pipeline import RAGpipeline
from stt.speech_to_text import SpeechToText
from llm.rag_prompt import build_rag_prompt
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

OUTPUT_DIR = os.path.join(BASE_DIR, "output")
UPLOAD_DIR = os.path.join(BASE_DIR, "uploads")

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)


os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # allow all for testing
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
@app.post("/process-text")
async def process_text(req: Request):
    data = await req.json()
    text = data.get("text", "")
    rag=RAGpipeline()
    print("***The Result from the input: ",text)
    retrieved_data=rag.retrieve(text,top_k=3)
    print("***The retrieved data: ",retrieved_data)
    prompt=build_rag_prompt(retrieved_data,text)
    llm=LocalLLM(model_path=r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\mistral\mistral-7b-instruct-v0.2.Q4_K_M.gguf")
    answer=llm.generate(prompt)
    print(answer)
    return JSONResponse({
        "text": answer
    })






