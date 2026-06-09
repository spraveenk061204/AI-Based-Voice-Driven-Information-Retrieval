import chromadb
from chromadb.config import Settings
import uuid

class ChromaStore:

    def __init__(self):
        self.client = chromadb.Client(
            Settings(persist_directory="backend/data/chroma_db")
        )

        self.collection = self.client.get_or_create_collection(
            name="rag_collection"
        )

    def add_documents(self, chunks, embeddings):

        # ✅ Prevent duplicate insertion
        if self.collection.count() > 0:
            print("[Chroma] Already populated, skipping...")
            return

        ids = [str(uuid.uuid4()) for _ in chunks]

        documents = [chunk.page_content for chunk in chunks]
        metadatas = [chunk.metadata for chunk in chunks]

        self.collection.add(
            ids=ids,
            documents=documents,
            metadatas=metadatas,
            embeddings=embeddings
        )

        print("[Chroma] Data stored successfully ✅")
    def get_all_documents(self):
        results = self.collection.get()

        docs = []
        for text, meta in zip(results["documents"], results["metadatas"]):
            from langchain_core.documents import Document
            docs.append(Document(page_content=text, metadata=meta))

        return docs


    def query(self, query_embedding, top_k=3):
        return self.collection.query(
            query_embeddings=[query_embedding],
            n_results=top_k
        )


    