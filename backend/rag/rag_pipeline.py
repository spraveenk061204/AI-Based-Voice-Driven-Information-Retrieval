# rag/rag_pipeline.py
import os
from rag.keyword_index import KeywordIndex
from llm.llama_model import LocalLLM
from llm.rag_prompt import build_rag_prompt
from llm.rag_prompt import build_rag_prompt
from rag.rag_chunker import Chunker
from rag.document_loader import DocLoader
from rag.embeder import Embeder
from rag.vector_store import VectorStore

PDF_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\backend\data\user_manual2.pdf"
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

        if os.path.exists(f"{VECTOR_PATH}/faiss.index"):
            print("[RAG] Loading vector store...")

            self.vector_store = VectorStore.load(VECTOR_PATH)
            '''new_docs = self.dl.loadWeb(WEB_URLS)
            for doc in new_docs:
                doc.metadata["source_type"] = "web"
                new_chunks = self.chunker.chunk_documents(new_docs)
                new_embeddings = self.embedder.embed_chunks(new_chunks)'''

            self.keyword_index = KeywordIndex(self.vector_store.chunks)
        else:
            print("[RAG] Building vector store...")
            self.vector_store = self.build_vector_store()
            self.keyword_index = KeywordIndex(self.vector_store.chunks)
    '''def build_vector_store(self):
        documents = []
          # Load PDF
        pdf_docs = self.dl.loadPDF(PDF_PATH)
        for doc in pdf_docs:
            doc.metadata["source_type"] = "pdf"
        # Load DOC
        docx_docs = self.dl.loadDoc(DOC_PATH)
        for doc in docx_docs:
            doc.metadata["source_type"] = "doc"
        documents.extend(pdf_docs)
        documents.extend(docx_docs)
        documents.extend(self.dl.loadWeb(WEB_URLS))
        print(f"[RAG] Loaded PDF: {len(pdf_docs)}, DOC: {len(docx_docs)}, Web: {len(self.dl.loadWeb(WEB_URLS))}")
        chunks = self.chunker.chunk_documents(documents)
        embeddings = self.embedder.embed_chunks(chunks)
        vector_store = VectorStore(len(embeddings[0]))
        vector_store.add_embeddings(embeddings, chunks)
        vector_store.save("backend/data/vector_store")
        return vector_store'''
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

        vector_store = VectorStore(len(embeddings[0]))
        vector_store.add_embeddings(embeddings, chunks)

        vector_store.save(VECTOR_PATH)

        return vector_store
    def retrieve(self, query_text, top_k=3):

        # ✅ VECTOR SEARCH
        query_embedding = self.embedder.queryEmbed([query_text])[0]
        vector_results = self.vector_store.similarity_search(query_embedding, top_k)

        # ✅ KEYWORD SEARCH
        keyword_results = self.keyword_index.search(query_text, top_k)

        # ✅ COMBINE RESULTS
        combined = vector_results + keyword_results

        # ✅ REMOVE DUPLICATES
        unique_docs = list({doc.page_content: doc for doc in combined}.values())

        return unique_docs[:top_k]