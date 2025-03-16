import os
from dotenv import load_dotenv
import requests

load_dotenv()

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