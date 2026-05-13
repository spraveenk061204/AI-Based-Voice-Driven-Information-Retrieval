# rag/rag_pipeline.py
import os

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

VECTOR_PATH = "backend/data/vector_store"
class RAGpipeline:
    
    def __init__(self):
            self.dl = DocLoader()
            self.chunker = Chunker(500, 100)
            self.embedder = Embeder(MODEL_PATH)

            if os.path.exists(f"{VECTOR_PATH}/faiss.index"):
                print("[RAG] Loading vector store...")
                self.vector_store = VectorStore.load(VECTOR_PATH)
            else:
                print("[RAG] Building vector store...")
                self.vector_store = self._build_vector_store()

    def _build_vector_store(self):
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

        print(f"[RAG] Loaded PDF: {len(pdf_docs)}, DOC: {len(docx_docs)}")

        chunks = self.chunker.chunk_documents(documents)

        embeddings = self.embedder.embed_chunks(chunks)

        vector_store = VectorStore(len(embeddings[0]))
        vector_store.add_embeddings(embeddings, chunks)

        # ✅ Save once
        vector_store.save("backend/data/vector_store")

        return vector_store
    '''def _build_vector_store(self):
        """
        Load ALL sources, chunk, embed, and store in one vector DB.
        """
        documents = []

    
        documents.extend(self.dl.loadWeb(WEB_URLS))

        print(f"[RAG] Total documents loaded: {len(documents)}")

        # ✅ Chunk everything together
        chunks = self.chunker.chunk_documents(documents)
        print(f"[RAG] Total chunks created: {len(chunks)}")

        # ✅ Embed once
        embeddings = self.embedder.embed_chunks(chunks)

        # ✅ Create vector store
        vector_store = VectorStore(len(embeddings[0]))
        vector_store.add_embeddings(embeddings, chunks)

        print("[RAG] Unified vector store ready")
        return vector_store'''

    def retrieve(self, query_text, top_k=3):
        """
        Search across PDF + Web + DOC simultaneously.
        """
        query_embedding = self.embedder.queryEmbed([query_text])[0]
        return self.vector_store.similarity_search(query_embedding, top_k)