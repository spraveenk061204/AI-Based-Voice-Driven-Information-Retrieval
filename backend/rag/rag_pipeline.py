# rag/rag_pipeline.py
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


class RAGpipeline:
    def __init__(self):
        self.dl = DocLoader()
        self.chunker = Chunker(chunk_size=500, chunk_overlap=100)
        self.embedder = Embeder(MODEL_PATH)

        # ✅ Build vector store ONCE
        self.vector_store = self._build_vector_store()

    def _build_vector_store(self):
        """
        Load ALL sources, chunk, embed, and store in one vector DB.
        """
        documents = []

        # ✅ Load all sources
        documents.extend(self.dl.loadPDF(PDF_PATH))
        documents.extend(self.dl.loadDoc(DOC_PATH))
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
        return vector_store

    def retrieve(self, query_text, top_k=3):
        """
        Search across PDF + Web + DOC simultaneously.
        """
        query_embedding = self.embedder.queryEmbed([query_text])[0]
        return self.vector_store.similarity_search(query_embedding, top_k)