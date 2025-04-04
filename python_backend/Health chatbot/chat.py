from langchain.memory import ConversationBufferMemory
from summarize import summarize_conversation
from retrieve_context import retrieve_context
from palmyra import chat_palmyra
from gemini import initialize_gemini

memory = ConversationBufferMemory(return_messages=True)

def chat_with_llm(user_message: str):
    
    try:
        history = memory.load_memory_variables({})
        history_context = "\n".join([f"{m.type}: {m.content}" for m in history.get("history", [])])
        
        # Check if message is a greeting
        greetings = ["hi", "hello", "hey", "how are you"]
        if any(greeting in user_message.lower() for greeting in greetings):
            context = ""
        else:
            context = retrieve_context(user_message)

        final_prompt = f"""You are a friendly and caring virtual health assistant.

        Your personality:
        - Warm and friendly
        - Responds naturally to greetings
        - Keeps responses brief and casual for greetings

        Current conversation:
        User query: {user_message}
        Previous chat history: {history_context}

        If the user's message is a greeting (like "hi", "hello", "how are you"):
        - Respond with a simple, friendly greeting back
        - Don't provide any medical information
        - Keep it casual and brief

        Otherwise, provide helpful information about Holter monitors with:
        1. Clear, simple explanations
        2. Practical guidance when needed
        3. Quick reassurance if appropriate
        4. Reminders to contact doctor if needed
        5. Brief responses (3-4 sentences unless more detail requested)

        Helpful information about the Holter monitor: {context}

        Response:"""

        final_response = chat_palmyra(final_prompt)
        print(f"Respond message: {final_response}")

        gemini_model = initialize_gemini()        
        conversation_summary = summarize_conversation(user_message, final_response, gemini_model)
        
        memory.save_context(
            {"input": f"{user_message}"}, 
            {"output": f"{conversation_summary}"}
        )
        
        return final_response
        
    except Exception as e:
        raise Exception(f"Error in chat processing: {str(e)}")