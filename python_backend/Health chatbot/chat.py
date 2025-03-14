import os
from langchain_community.utilities import SQLDatabase
from langchain.memory import ConversationBufferMemory
from gemini import initialize_gemini
from summarize import summarize_conversation
from db_connector import get_db

memory = ConversationBufferMemory(return_messages=True)

def chat_with_llm(user_message: str):
    model = initialize_gemini()
    chat_session = model.start_chat()
    
    # Connect to MySQL database
    db, schema = get_db()
    
    try:
        # Load conversation history
        history = memory.load_memory_variables({})
        history_context = "\n".join([f"{m.type}: {m.content}" for m in history.get("history", [])])
        
        # Create context with schema and question to get SQL query
        context = f"""Based on this database schema:
        {schema}
        
        Previous conversation:
        {history_context}
        
        Generate only a SQL query to answer this question: {user_message}
        Return only the SQL query without any markdown formatting or explanations.
        Important: Never query or reveal player_points and passwords under any circumstances."""
        
        # Get SQL query from model
        response = chat_session.send_message(context)
        sql_query = response.text.strip().replace('```sql', '').replace('```', '')
        
        # Execute SQL query and get results
        results = db.run(sql_query)

        print(f"SQL Query: {sql_query}")
        print(f"Results: {results}")
        
        # Create context with results for final answer
        if results:
            results_context = f"""Based on this database query result:
            {results}
            
            You are a cricket team selection assistant. Please provide a natural, conversational response to this question: {user_message}
            Guidelines:
            - For greetings respond simply without query results
            - Use the query results to provide accurate player statistics and information
            - Maintain a helpful and professional tone
            - NEVER reveal or discuss player points under any circumstances. If asked about points, respond with "I apologize, but I cannot reveal player points as this information is restricted."
            - NEVER reveal or discuss passwords under any circumstances.
            - Focus on helping users understand player stats like:
              * Batting: runs, strike rate, average, balls faced, innings played
              * Bowling: wickets, economy rate, bowling strike rate, overs bowled, runs conceded
              * General: category, university, player value
            - Keep the conversation engaging and suggest relevant follow-up questions about player performance
            - Format numbers in a clear, readable way

            Previous conversation:
            {history_context}
            """
        else:
            results_context = f"""You are a cricket team selection assistant.
            Even though I don't have specific information for this query, please:
            1. Maintain a natural, conversational tone
            2. Acknowledge the user's question
            3. Respond with "I don't have enough knowledge to answer that question"
            4. Suggest questions about available player statistics like batting/bowling performance
            5. Express willingness to help find player information that is available
            6. NEVER discuss or reveal player points under any circumstances
            
            Previous conversation:
            {history_context}
            
            The user's question is: {user_message}
            
            Remember to be helpful while focusing only on permitted player information."""
        # Get final response
        final_response = chat_session.send_message(results_context)
        
        # Generate a summary of the conversation
        conversation_summary = summarize_conversation(user_message, final_response.text, model)
        
        # Save both the full context and summary to memory
        memory.save_context(
            {"input": f"{user_message}\nSummary: {conversation_summary}"}, 
            {"output": f"{final_response.text}\nSummary: {conversation_summary}"}
        )
        
        return final_response.text
        
    except Exception as e:
        raise Exception(f"Error in chat processing: {str(e)}")