from langchain_community.document_loaders import PyPDFLoader
from langchain_community.document_loaders import WebBaseLoader
from langchain_community.document_loaders import Docx2txtLoader



class DocLoader:

    
    def loadPDF(self,file_path):
        """
        Loads a PDF and returns LangChain Document objects.
        """
        loader = PyPDFLoader(file_path)
        documents = loader.load()
        return documents
    def loadWeb(self,urls):
        print("[WebSource] Loading web documents using LangChain")
        
        loader = WebBaseLoader(
            urls,
            requests_kwargs={"verify": False}  # Windows SSL fix
        )

        documents = loader.load()
        return documents
    def loadDoc(self,file_path):
        """
        Loads a DOCX file and returns LangChain Document objects.
        """
        print("[DocSource] Loading Word document using LangChain")
        loader = Docx2txtLoader(file_path)
        documents = loader.load()
        return documents



    


