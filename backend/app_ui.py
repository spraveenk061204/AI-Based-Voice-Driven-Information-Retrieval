import streamlit as st
import os
import tempfile

# -----------------------------
# Backend Imports
# -----------------------------
from llm.llama_model import LocalLLM
from llm.rag_prompt import build_rag_prompt
from rag.rag_pipeline import RAGpipeline
from stt.speech_to_text import SpeechToText
from tts.text_to_speech import TextToSpeech

# -----------------------------
# Paths
# -----------------------------
WHISPER_MODEL_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\faster-whisper"
LLM_MODEL_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\mistral\mistral-7b-instruct-v0.2.Q4_K_M.gguf"
BARK_MODEL_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\models\bark-small"
AUDIO_OUTPUT = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\backend\output\response.wav"

# -----------------------------
# Load Backend ONCE
# -----------------------------

def load_backend():
    rag = RAGpipeline()
    llm = LocalLLM(model_path=LLM_MODEL_PATH)
    tts = TextToSpeech(BARK_MODEL_PATH)
    stt = SpeechToText(WHISPER_MODEL_PATH)
    return rag, llm, tts, stt

rag, llm, tts, stt = load_backend()

# -----------------------------
# Streamlit UI
# -----------------------------
st.set_page_config(page_title="AI Voice Retrieval System", layout="centered")

st.title("🎤 AI Voice Retrieval System")
st.caption("Voice → RAG → LLM → TTS (Streamlit Demo)")

if st.button("🔄 Reload backend", use_container_width=True):
    with st.spinner("Reloading backend resources..."):
        load_backend.clear()
        rag, llm, tts, stt = load_backend()
    st.success("Backend reloaded")

st.divider()

# -----------------------------
# Voice Input
# -----------------------------
st.subheader("Speak Your Question")

audio_bytes = st.audio_input("Tap and speak")

query_text = ""

if audio_bytes:
    # Save audio temporarily
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
        tmp.write(audio_bytes.getvalue())
        audio_path = tmp.name

    st.success("Voice recorded")

    with st.spinner("Transcribing with Whisper..."):
        query_text = stt.transcribe_audio(audio_path)

    st.subheader("Recognized Speech")
    st.text_area("", value=query_text, height=80)

# -----------------------------
# Run Full Pipeline
# -----------------------------
if query_text and st.button("🔍 Generate Answer", use_container_width=True):

    with st.spinner("Retrieving relevant documents..."):
        docs = rag.retrieve(query_text, top_k=3)

    with st.spinner("Generating answer using LLM..."):
        prompt = build_rag_prompt(docs, query_text)
        answer = llm.generate(prompt)

    st.success("Answer generated")

    st.subheader("Answer")
    st.text_area("", value=answer, height=180)

    with st.spinner("Generating voice response with Bark..."):
        audio_path = tts.synthesize(answer, AUDIO_OUTPUT)

    st.subheader("Audio Output")
    if os.path.exists(audio_path):
        st.audio(audio_path)
    else:
        st.error("Audio not generated")

# -----------------------------
# Footer
# -----------------------------
st.divider()
st.caption("Demo-ready Streamlit frontend with real voice input")