import os
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

Palmyra_API_KEY = os.getenv("Palmyra_API_KEY")

client = OpenAI(
  base_url = "https://integrate.api.nvidia.com/v1",
  api_key = Palmyra_API_KEY
)

def chat_palmyra(user_query):
    completion = client.chat.completions.create(
    model="writer/palmyra-med-70b-32k",
    messages=[{"role":"user","content":f"{user_query}"}],
    temperature=0.2,
    top_p=0.7,
    max_tokens=4096,
    stream=False
    )

    response = completion.choices[0].message.content
    return response

# respond = chat_palmyra('Hi')
# print(respond)