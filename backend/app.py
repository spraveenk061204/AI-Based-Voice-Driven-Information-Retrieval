from fastapi import FastAPI
from fastapi.responses import  JSONResponse
import os
from fastapi import Request

from llm.llama_model import LocalLLM
from rag.rag_pipeline import RAGpipeline
from llm.rag_prompt import build_rag_prompt
from fastapi.middleware.cors import CORSMiddleware

from pymongo import MongoClient

app = FastAPI()

client = MongoClient("mongodb://localhost:27017/")

db = client["voice_ai_app"]

chat_collection = db["chats"]

print("MongoDB connected")


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
    chat_id = data.get("chat_id", "default")
    chat = chat_collection.find_one({"_id": chat_id})
    
    if not chat:
        chat_collection.insert_one({
            "_id": chat_id,
            "title": text[:40],   # ✅ ADD TITLE
            "messages": []
        })
        chat = {"_id": chat_id, "messages": []}
    else:
        if not chat.get("title") or chat.get("title") == "New Chat":
            chat_collection.update_one(
                {"_id": chat_id},
                {
                    "$set": {
                        "title": text[:40]
                    }
                }
            )
    messages = chat["messages"]
    messages.append({"role": "user", "content": text})


    rag=RAGpipeline()
    print("***The Result from the input: ",text)
    retrieved_data=rag.retrieve(text,top_k=3)
    print("***The retrieved data: ",retrieved_data)
    prompt=build_rag_prompt(retrieved_data,text,messages)
    llm=LocalLLM(model_path=r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\mistral\mistral-7b-instruct-v0.2.Q4_K_M.gguf")
    answer=llm.generate(prompt)
    print(answer)
    
  # ✅ STORE ASSISTANT
    messages.append({
        "role": "assistant",
        "content": answer
    })
    chat_collection.update_one(
    {"_id": chat_id},
    {"$push": {
        "messages": {
            "$each": [
                {"role": "user", "content": text},
                {"role": "assistant", "content": answer}
            ]
        }
    }},
    upsert=True
)

    return JSONResponse({
        "text": answer
    })


@app.get("/get-chats")
def get_chats():

    chats = chat_collection.find({}, {"_id": 1, "title": 1})

    chat_list = []

    for chat in chats:
        chat_list.append({
            "chat_id": chat["_id"],
            "title": chat.get("title", "New Chat")
        })

    return {"chats": chat_list}


@app.get("/get-chat/{chat_id}")
def get_chat(chat_id: str):
    chat = chat_collection.find_one({"_id": chat_id})
    if not chat:
        return JSONResponse(status_code=404, content={"message": "Chat not found"})
    return {"chat_id": chat["_id"], "messages": chat["messages"]}