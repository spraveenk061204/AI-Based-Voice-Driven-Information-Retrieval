from sklearn.feature_extraction.text import TfidfVectorizer
import numpy as np

class KeywordIndex:
    def __init__(self, chunks):
        self.chunks = chunks
        self.texts = [doc.page_content for doc in chunks]

        self.vectorizer = TfidfVectorizer()
        self.matrix = self.vectorizer.fit_transform(self.texts)

    def search(self, query, top_k=3):
        query_vec = self.vectorizer.transform([query])
        scores = (self.matrix @ query_vec.T).toarray().flatten()

        indices = np.argsort(scores)[::-1][:top_k]
        return [self.chunks[i] for i in indices]