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
from tts.text_to_speech import TextToSpeech

from fastapi.middleware.cors import CORSMiddleware


MODEL_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\faster-whisper"

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
    # ✅ Save uploaded file
    #input_filename = f"{uuid.uuid4()}.m4a"
    #input_path = os.path.join(UPLOAD_DIR, input_filename)

    #with open(input_path, "wb") as buffer:
        #shutil.copyfileobj(audio.file, buffer)

    #stt=SpeechToText(MODEL_PATH)
    rag=RAGpipeline()
    
    llm = LocalLLM(
        model_path=r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\mistral\mistral-7b-instruct-v0.2.Q4_K_M.gguf"
    )

    #result=stt.transcribe_audio(input_path)
    print("***The Result from the input: ",text)
    retrieved_data=rag.retrieve(text,3)
    prompt = build_rag_prompt(retrieved_data,text)
    answer = llm.generate(prompt)
    print(answer)
    tts=TextToSpeech(r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\models\bark-small")
   
    output_filename = "response.wav"
    audio_path = os.path.join(OUTPUT_DIR, output_filename)
    
   
    tts.synthesize(answer, audio_path)

    print("Audio saved at:", audio_path)

    return JSONResponse({
        "audio_url": f"http://localhost:8000/audio/{output_filename}",
        "text": answer
    })



@app.get("/audio/{filename}")
def get_audio(filename: str):
    return FileResponse(os.path.join(OUTPUT_DIR, filename))




