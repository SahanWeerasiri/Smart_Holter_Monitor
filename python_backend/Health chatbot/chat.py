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
        
        context = retrieve_context(user_message)

        final_prompt = f"""
        user query = {user_message}
        chat history = {history_context}
        additional context = {context}
        """
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