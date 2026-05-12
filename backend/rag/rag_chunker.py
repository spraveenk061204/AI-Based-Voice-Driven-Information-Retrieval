from tabulate import tabulate
from  langchain_text_splitters import  RecursiveCharacterTextSplitter

class Chunker:
    def __init__(self,chunk_size,chunk_overlap):
        self.chunk_size=chunk_size
        self.chunk_overlap=chunk_overlap

        
    def chunk_documents(self,documents):
      
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=self.chunk_size,
            chunk_overlap=self.chunk_overlap,
            separators=["\n\n", "\n", ".", " ", ""]
        )

        chunks = text_splitter.split_documents(documents)
        return chunks

    def print_chunks_table_pretty(self,chunks, preview_chars=100):
        table_data = []

        for idx, chunk in enumerate(chunks):
            preview = chunk.page_content.replace("\n", " ")
            preview = preview[:preview_chars] + "..." if len(preview) > preview_chars else preview
            table_data.append([idx, preview])

        print("\nCHUNKS TABLE\n")
        print(tabulate(
            table_data,
            headers=["Chunk ID", "Page Content (Preview)"],
            tablefmt="grid"
        ))
