import faiss
import numpy as np
from typing import List

from tabulate import tabulate
from rag.embeder import Embeder
from rag.rag_chunker import Chunker
from rag.document_loader import DocLoader

PDF_PATH = "C:/Users/s.praveenk/Documents/Projects/Poc-AI Based Voice retrieval/backend/data/user_manual.pdf"
MODEL_PATH = r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\all-mini-lm-v6"
class VectorStore:
    def __init__(self, embedding_dimension: int):
        """
        Initialize FAISS index
        """
        self.embedding_dimension = embedding_dimension
        self.index = faiss.IndexFlatL2(embedding_dimension)
        self.chunks = []  # stores chunk objects (Document)

    def add_embeddings(self, embeddings: List[List[float]], chunks: List):
        """
        Add embeddings and corresponding chunks to FAISS
        """
        if len(embeddings) != len(chunks):
            raise ValueError("Embeddings count must match chunks count")

        print("Adding embeddings to FAISS index...")

        vectors = np.array(embeddings).astype("float32")
        self.index.add(vectors)

        self.chunks.extend(chunks)

        print(f" Total vectors stored in FAISS: {self.index.ntotal}")

    def similarity_search(self, query_embedding, top_k: int = 3):
        """
        Perform similarity search on FAISS index
        """
        query_vector = np.array([query_embedding]).astype("float32")

        distances, indices = self.index.search(query_vector, top_k)

        results = []
        for idx in indices[0]:
            if idx < len(self.chunks):
                results.append(self.chunks[idx])

        return results

    def print_index_table(self, preview_chars: int = 20):
        """
        Print FAISS index as a table for debugging
        """
        print("\nVECTOR STORE TABLE")
        table_data = []

        for idx, chunk in enumerate(self.chunks):
            preview = chunk.page_content.replace("\n", " ")
            preview = preview[:preview_chars] + "..." if len(preview) > preview_chars else preview
            page = chunk.metadata.get("page_label", "N/A")
            source = chunk.metadata.get("source", "N/A")
            table_data.append([idx,page,source,preview])

            
            print(tabulate(
            table_data,
            headers=["Chunk_ID", "Page Content", "Source", "Preview"],
            tablefmt="grid"
        ))
            
            

        print("=" * 140)


