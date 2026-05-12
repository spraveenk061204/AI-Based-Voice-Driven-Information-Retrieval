def build_rag_prompt(context_chunks, user_query):
    context_text = "\n\n".join(
        chunk.page_content for chunk in context_chunks
    )

    prompt = f"""
You are a helpful technical assistant.
Use ONLY the information provided below.
If the answer is not present, say "I don't know".

Context:
{context_text}

Question:
{user_query}

Answer:
"""
    return prompt.strip()