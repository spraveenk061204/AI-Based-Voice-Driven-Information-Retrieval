from sentence_transformers import SentenceTransformer
from typing import List
MODEL_PATH=r"C:\Users\s.praveenk\Documents\Projects\Poc-AI Based Voice retrieval\all-mini-lm-v6"


class Embeder:

    def __init__(self,model_path):
        self.model= SentenceTransformer(model_path)

    def embed_chunks(self,chunks):
        """
        Convert document chunks into embeddings
        """
        print("Generating embeddings for chunks...")

        texts = [chunk.page_content for chunk in chunks]
        embeddings = self.model.encode(texts, show_progress_bar=True)

        return embeddings

    def print_embeddings_table(self,chunks, embeddings, preview_chars=80):
        """
        Print Chunk ID | Content Preview | Embedding Dimension
        """
        print("\nEMBEDDINGS TABLE")
        print("=" * 120)
        print(f"{'Chunk ID':<10} | {'Content Preview':<85} | {'Embedding Size'}")
        print("=" * 120)

        for idx, (chunk, emb) in enumerate(zip(chunks, embeddings)):
            preview = chunk.page_content.replace("\n", " ")
            preview = preview[:preview_chars] + "..." if len(preview) > preview_chars else preview
            print(f"{idx:<10} | {preview:<85} | {len(emb)}")

        print("=" * 120)
    def queryEmbed(self,query):
        query_embedding=self.model.encode(query)
        return query_embedding
    


"""if __name__ == "__main__":
    # Import chunker functions
    
    from chunker import Chunker
    from document_loader import DocLoader
    pdf_path = "C:\\Users\\s.praveenk\\Documents\\Projects\\Poc-AI Based Voice retrieval\\backend\\data\\user_manual.pdf"

    # Load & chunk documents
    chunk = Chunker(500,100)
    dl=DocLoader(pdf_path)
    documents = dl.loadPDF()
    chunks = chunk.chunk_documents(documents)
   

    # Load embedding model
    embedding_model = load_embedding_model(MODEL_PATH)

    # Generate embeddings
    embeddings = embed_chunks(chunks, embedding_model)

    # Print in table format
    print_embeddings_table(chunks, embeddings)

    print("\n✅ Embedding generation completed successfully")
    print(f"Total Chunks   : {len(chunks)}")
    print(f"Embedding Size : {len(embeddings[0])}")"""