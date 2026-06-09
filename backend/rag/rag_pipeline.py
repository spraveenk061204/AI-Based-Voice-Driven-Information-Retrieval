# rag/rag_pipeline.py
import os
from rag.keyword_index import KeywordIndex
from llm.rag_prompt import build_rag_prompt
from rag.rag_chunker import Chunker
from rag.document_loader import DocLoader
from rag.embeder import Embeder
from rag.chroma_store import ChromaStore
from langchain_core.documents import Document


PDF_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\backend\data\multi_sfs.pdf"
DOC_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\backend\data\User-Manual-Work-Instruction.docx"

WEB_URLS = [
    "https://en.wikipedia.org/wiki/Artificial_intelligence",
    "https://www.techopedia.com/definition/190/artificial-intelligence-ai"
]
MODEL_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\all-mini-lm-v6"
LLM_MODEL_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\mistral\mistral-7b-instruct-v0.2.Q4_K_M.gguf"
VECTOR_PATH = "backend/data/vector_store"
class RAGpipeline:

    def __init__(self):
        self.dl = DocLoader()
        self.chunker = Chunker(500, 100)
        self.embedder = Embeder(MODEL_PATH)

        self.vector_store = ChromaStore()

        if self.vector_store.collection.count() == 0:
            print("[RAG] Building vector store...")
            self.build_vector_store()

        else:
            print("[RAG] Using existing ChromaDB ")

     
        self.chunks = self.vector_store.get_all_documents()

        self.keyword_index = KeywordIndex(self.chunks)

    def build_vector_store(self):
        documents = []

        pdf_docs = self.dl.loadPDF(PDF_PATH)
        for doc in pdf_docs:
            doc.metadata["source_type"] = "pdf"

        docx_docs = self.dl.loadDoc(DOC_PATH)
        for doc in docx_docs:
            doc.metadata["source_type"] = "doc"

        web_docs = self.dl.loadWeb(WEB_URLS)
        for doc in web_docs:
            doc.metadata["source_type"] = "web"

        documents.extend(pdf_docs)
        documents.extend(docx_docs)
        documents.extend(web_docs)

        chunks = self.chunker.chunk_documents(documents)
        embeddings = self.embedder.embed_chunks(chunks)

        # Store in Chroma only
        self.vector_store.add_documents(chunks, embeddings)

    def retrieve(self, query_text, top_k=3):

        # VECTOR SEARCH (Chroma)
        query_embedding = self.embedder.queryEmbed([query_text])[0]

        results = self.vector_store.query(query_embedding, top_k)

        vector_docs = []
        for text, meta in zip(
            results["documents"][0],
            results["metadatas"][0]
        ):
            vector_docs.append(Document(page_content=text, metadata=meta))

        #  KEYWORD SEARCH
        keyword_results = self.keyword_index.search(query_text, top_k)

        # COMBINE
        combined = vector_docs + keyword_results

        #  REMOVE DUPLICATES
        unique_docs = list({doc.page_content: doc for doc in combined}.values())

        return unique_docs[:top_k]
