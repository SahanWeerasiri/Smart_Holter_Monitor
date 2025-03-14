import time
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from Chatbot import initialize_clients, generate_response
from Vector_DB_Creator import create_vector_db, create_candidate_vector_stores, create_election_instructions_vector_store, create_political_parties_vector_store
from win_predictor import initialize_clients_2, extract_data_from_urls, analyze_content, load_polling_data
from Comparator import initialize_clients_3, compare_candidates
from fake_detection import initialize_clients_4, verify_claim_hiss
from menifesto_chatbot import generate_manifesto_response, initialize_clients_5
import logging
import requests
import json
import os
# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

# CORS configuration
origins = [
    "http://localhost",
    "http://localhost:8501",
    "http://127.0.0.1:8501",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize client and vector stores
try:
    Chat_LLAMA_client, Chat_tavily_client, Chat_memory, Chat_gemini_model = initialize_clients()
    Pred_LLAMA_client, Pred_tavily_client = initialize_clients_2()
    Comp_LLAMA_client = initialize_clients_3()
    Fake_LLAMA_client, Fake_tavily_client, Fake_SLM = initialize_clients_4()
    Manifesto_Chat_memory, Manifesto_Chat_gemini_model = initialize_clients_5()

    vector_store = create_vector_db()
    candidate_vector_stores = create_candidate_vector_stores()
    election_instructions_vector_store = create_election_instructions_vector_store()
    political_parties_vector_store = create_political_parties_vector_store()

    if vector_store is None or candidate_vector_stores is None or election_instructions_vector_store is None or political_parties_vector_store is None:
        logger.error("Vector store or candidate vector stores are not initialized.")
except Exception as e:
    logger.error(f"Initialization error: {e}")
    vector_store = None
    candidate_vector_stores = None

class Query(BaseModel):
    prompt: str
    language: str = Field(default="English", description="Language of the prompt and response")

class ComparisonQuery(BaseModel):
    candidates: list[str]
    topics: list[str]

AZURE_TRANSLATE_ENDPOINT = os.getenv("AZURE_TRANSLATE_ENDPOINT")
AZURE_TRANSLATE_KEY = os.getenv("AZURE_TRANSLATE_KEY")

def translate_text(text, from_lang, to_lang):
    headers = {
        'Ocp-Apim-Subscription-Key': AZURE_TRANSLATE_KEY,
        'Ocp-Apim-Subscription-Region': 'southeastasia', 
        'Content-type': 'application/json'
    }
    params = {
        'api-version': '3.0',
        'from': from_lang,
        'to': to_lang
    }
    body = [
        {'Text': text}
    ]
    response = requests.post(
        AZURE_TRANSLATE_ENDPOINT,
        params=params,
        headers=headers,
        json=body
    )
    response.raise_for_status()
    return response.json()[0]['translations'][0]['text']


@app.get("/")
async def root():
    logger.info("Root endpoint accessed.")
    return {"message": "Hello World"}

@app.post("/generate")
async def generate(query: Query):
    start_time = time.time()
    logger.info(f"Received prompt: {query.prompt} in language: {query.language}")
    if vector_store is None:
        logger.error("Vector store is not initialized.")
        return {"error": "Vector store is not initialized."}
    try:
        # Translate prompt to English if necessary
        if query.language.lower() == "english":
            translated_prompt = query.prompt
        elif query.language.lower() == "sinhala":
            translated_prompt = translate_text(query.prompt, "si", "en")
            print(translated_prompt)
        elif query.language.lower() == "tamil":
            translated_prompt = translate_text(query.prompt, "ta", "en")
        else:
            return {"error": "Unsupported language selected."}

        response, Agent = await generate_response(translated_prompt, Chat_LLAMA_client, Chat_tavily_client, vector_store, election_instructions_vector_store, political_parties_vector_store, Chat_memory, 1,Chat_gemini_model)
        print(Agent)
        # Translate response back to the selected language if necessary
        if query.language.lower() == "english":
            translated_response = response
        elif query.language.lower() == "sinhala":
            translated_response = translate_text(response, "en", "si")
        elif query.language.lower() == "tamil":
            translated_response = translate_text(response, "en", "ta")
        else:
            translated_response = response  # Fallback

        logger.info(f"Generated response: {translated_response}")
        end_time = time.time()
        total_time = end_time - start_time
        logger.info(f"Full time: {total_time:.2f} seconds")
        return {"response": translated_response, "agent": Agent}
    except Exception as e:
        logger.error(f"Error generating response: {e}", exc_info=True)
        end_time = time.time()
        total_time = end_time - start_time
        logger.info(f"Full time: {total_time:.2f} seconds")
        return {"error": "Failed to generate response."}

@app.post("/manifestochat")
async def manifestochat(query: Query):
    start_time = time.time()
    logger.info(f"Received prompt: {query.prompt} in language: {query.language}")
    if candidate_vector_stores is None:
        logger.error("Candidate vector stores are not initialized.")
        return {"error": "Candidate vector stores are not initialized."}
    try:
        # Translate prompt to English if necessary
        if query.language.lower() == "english":
            translated_prompt = query.prompt
        elif query.language.lower() == "sinhala":
            translated_prompt = translate_text(query.prompt, "si", "en")
            print(translated_prompt)
        elif query.language.lower() == "tamil":
            translated_prompt = translate_text(query.prompt, "ta", "en")
        else:
            return {"error": "Unsupported language selected."}

        response = await generate_manifesto_response(translated_prompt, candidate_vector_stores, Manifesto_Chat_memory, Manifesto_Chat_gemini_model)

        # Translate response back to the selected language if necessary
        if query.language.lower() == "english":
            translated_response = response
        elif query.language.lower() == "sinhala":
            translated_response = translate_text(response, "en", "si")
        elif query.language.lower() == "tamil":
            translated_response = translate_text(response, "en", "ta")
        else:
            translated_response = response  # Fallback

        logger.info(f"Generated response: {translated_response}")
        end_time = time.time()
        total_time = end_time - start_time
        logger.info(f"Full time: {total_time:.2f} seconds")
        return {"response": translated_response}
    except Exception as e:
        logger.error(f"Error generating response: {e}", exc_info=True)
        end_time = time.time()
        total_time = end_time - start_time
        logger.info(f"Full time: {total_time:.2f} seconds")
        return {"error": "Failed to generate response."}

@app.post("/compare")
async def compare(query: ComparisonQuery):
    logger.info(f"Received comparison request for {', '.join(query.candidates)}")
    if candidate_vector_stores is None:
        logger.error("Candidate vector stores are not initialized.")
        return {"error": "Candidate vector stores are not initialized."}
    try:
        # Use the relevant candidate vector stores for comparison
        relevant_vector_stores = {candidate: candidate_vector_stores[candidate] for candidate in query.candidates if candidate in candidate_vector_stores}
        
        # Check if any of the relevant vector stores is None
        if any(store is None for store in relevant_vector_stores.values()):
            logger.error("One or more candidate vector stores are None.")
            return {"error": "One or more candidate vector stores are not initialized."}
        
        # Generate a unique filename based on sorted candidate names
        filename = f"comparisons/{'_'.join(sorted(query.candidates))}_{'_'.join(sorted(query.topics))}.json"
        
        # Check if the comparison already exists
        if os.path.exists(filename):
            with open(filename, 'r') as file:
                comparison = json.load(file)
            logger.info(f"Retrieved existing comparison from {filename}")
        else:
            # Generate new comparison
            comparison = await compare_candidates(query.candidates, Comp_LLAMA_client, relevant_vector_stores, query.topics)
            
            # Ensure the comparisons directory exists
            os.makedirs('comparisons', exist_ok=True)
            
            # Save the new comparison
            with open(filename, 'w') as file:
                json.dump(comparison, file)
            logger.info(f"Generated new comparison and saved to {filename}")
        logger.info(f"Generated comparison: {comparison}")
        return {"comparison": comparison}
    except Exception as e:
        logger.error(f"Error generating comparison: {e}", exc_info=True)
        return {"error": f"Failed to generate comparison: {str(e)}"}

@app.get("/win_predictor")
async def win_predictor():
    logger.info("Win predictor endpoint accessed.")
    try:
        polling_data = load_polling_data("polling_data.json")
        if not polling_data:
            logger.error("Failed to load polling data.")
            return {"error": "Failed to load polling data."}

        # Generate a unique filename for the win predictor analysis
        filename = os.path.join(os.path.dirname(__file__), "win_predictor_analysis.json")
        
        # Check if the analysis already exists
        if os.path.exists(filename):
            with open(filename, 'r') as file:
                analysis = json.load(file)
            logger.info(f"Retrieved existing win predictor analysis from {filename}")
        else:
            urls = [
                "https://numbers.lk/analysis/akd-maintains-lead-in-numbers-lk-s-2nd-pre-election-poll-ranil-surges-to-second-place",
                "https://www.ihp.lk/press-releases/ak-dissanayake-and-sajith-premadasa-led-august-voting-intent-amongst-all-adults"
            ]
            web_scraped_content = extract_data_from_urls(urls)
            analysis = await analyze_content(polling_data, web_scraped_content, Pred_LLAMA_client, Pred_tavily_client)
            
            # Save the new analysis
            with open(filename, 'w') as file:
                json.dump(analysis, file)
            logger.info(f"Generated new win predictor analysis and saved to {filename}")

        logger.info(f"Generated win predictor analysis: {analysis}")
        return {"data": analysis}
    except Exception as e:
        logger.error(f"Error in win predictor: {e}")
        return {"error": "Failed to generate win predictor analysis."}

@app.post("/fake_detection")
async def fake_detection(claim: Query): 
    logger.info(f"Received fake detection request for {claim.prompt}")
    try:
        final_prediction, verifications = verify_claim_hiss(claim.prompt, Fake_LLAMA_client, Fake_tavily_client, Fake_SLM)
        return {"response": final_prediction, "verifications": verifications}
    except Exception as e:
        logger.error(f"Error in fake detection: {e}")
        return {"error": "Failed to generate fake detection response."}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)