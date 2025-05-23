import os
from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings
from sentence_transformers import SentenceTransformer

similarity_model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')


def retrieve_context(query, top_k=4):
    script_dir = os.path.dirname(os.path.realpath(__file__))
    embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")


    path = os.path.join(script_dir, "Vector_DB")
    vector_store = FAISS.load_local(path, embeddings, allow_dangerous_deserialization=True)

    # Get results from each store
    results = vector_store.similarity_search_with_score(query+query+query+query+query, k=top_k)

    results.sort(key=lambda x: x[1], reverse=True)
    weighted_context = ""
    for doc, score in results:
        weighted_context += f"{doc.page_content} (relevance: {score})\n\n"
        
    return weighted_context

