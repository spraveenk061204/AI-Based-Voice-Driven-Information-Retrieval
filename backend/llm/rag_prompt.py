def build_rag_prompt(context_chunks, user_query, history):

    context_text = "\n\n".join(
        chunk.page_content for chunk in context_chunks
    )

    # ✅ Keep only last few messages (VERY IMPORTANT)
    history = history[-6:]

    conversation = ""
    for msg in history[:-1]:   # ❗ exclude latest question
        if msg["role"] == "user":
            conversation += f"User: {msg['content']}\n"
        else:
            conversation += f"Assistant: {msg['content']}\n"

    prompt = f"""
You are a helpful assistant.

STRICT RULES:
- Use only the provided context
- Answer ONLY the latest question
- Do NOT repeat conversation
- Do NOT include 'User' or 'Assistant'
- Do NOT include 'Answer:' or any labels
- Keep answer short (2–3 lines OR bullet points)

Context:
{context_text}

Conversation (for reference only):
{conversation}

User Question:
{user_query}

Final Answer:
"""

    return prompt.strip()