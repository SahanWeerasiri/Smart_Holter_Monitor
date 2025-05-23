from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from chat import chat_with_llm
from translator import translate_text

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    message: str
    language: str

class ChatResponse(BaseModel):
    response: str

@app.post("/chat")
def chat_endpoint(request: ChatRequest):
    try:
        print(f"Received message: {request.message}")
        
        # Translate input to English if needed
        if request.language.lower() == "english":
            translated_prompt = request.message
        elif request.language.lower() == "sinhala":
            translated_prompt = translate_text(request.message, "si", "en")
            print(translated_prompt)
        elif request.language.lower() == "tamil":
            translated_prompt = translate_text(request.message, "ta", "en")
        
        # Get response in English
        response = chat_with_llm(translated_prompt)
        
        # Translate response back to requested language
        if request.language.lower() != "english":
            if request.language.lower() == "sinhala":
                response = translate_text(response, "en", "si")
            elif request.language.lower() == "tamil":
                response = translate_text(response, "en", "ta")
        
        print(response)
        return ChatResponse(response=response)
    except Exception as e:
        print(f"Error in chat_endpoint: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)