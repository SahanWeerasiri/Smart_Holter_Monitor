import requests

def chat_with_bot():
    # Initialize chat session
    url = "http://localhost:8000/chat"
    session = requests.Session()
    
    print("Chat with the cricket team selection assistant (type 'quit' to exit)")
    print("Select language (english/sinhala/tamil):")
    language = input().lower().strip()
    print("=" * 50)
    
    while True:
        # Get user input
        user_message = input("\nYou: ").strip()
        
        # Check if user wants to quit
        if user_message.lower() == 'quit':
            print("\nGoodbye!")
            break
            
        try:
            # Send request to chat endpoint
            response = session.post(
                url,
                json={
                    "message": user_message,
                    "language": language
                }
            )
            
            # Check if request was successful
            response.raise_for_status()
            
            # Get and print bot response
            bot_response = response.json()["response"]
            print("\nBot:", bot_response)
            
        except requests.exceptions.RequestException as e:
            print(f"\nError communicating with server: {str(e)}")
        except Exception as e:
            print(f"\nUnexpected error: {str(e)}")

if __name__ == "__main__":
    chat_with_bot()
