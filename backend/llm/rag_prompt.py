def build_rag_prompt(context_chunks, user_query):
    context_text = "\n\n".join(
        chunk.page_content for chunk in context_chunks
    )

    prompt = f"""
You are a helpful technical assistant.
Use ONLY the information provided below.
If the answer is not present, say "I don't know".


Rules:
- Add welcome message like "Hello! How can I assist you today?" when user says "Hey Assistant".
- Use the provided context to answer the question.
- Keep the answer BRIEF
- If the answer is like instructions, steps, or a list, format it as a bullet list.
- Do NOT give long explanations
- If you don't know the answer, say "I don't know"
- Be clear and direct
- Answer ONLY the question
- Do NOT repeat the entire context
- Do NOT include "Question" or "Answer"
- Provide a short answer (2–3 lines)
- If steps are needed, provide only the final steps



Context:
{context_text}

Question:
{user_query}

Answer:
"""
    return prompt.strip()