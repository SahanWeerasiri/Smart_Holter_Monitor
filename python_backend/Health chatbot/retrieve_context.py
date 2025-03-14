import os
from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings
from sentence_transformers import SentenceTransformer

similarity_model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')


def retrieve_context(query, top_k=4):
    script_dir = os.path.dirname(os.path.realpath(__file__))
    embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
    
    # Define available stores
    store_names = [
        "ben_shapiro_destiny_debate_transcript_vector_store",
        "elon_musk_transcript_vector_store", 
        "sam_altman_transcript_vector_store",
        "yann_lecun_transcript_vector_store"
    ]
    
    # Calculate similarity between query and store names
    query_embedding = similarity_model.encode(query)
    store_embeddings = similarity_model.encode([name.replace("_transcript_vector_store", "").replace("_", " ") for name in store_names])
    similarities = [query_embedding @ store_embedding for store_embedding in store_embeddings]
    
    # Select relevant stores based on similarity threshold
    similarity_threshold = 0.3
    relevant_stores = [name for name, sim in zip(store_names, similarities) if sim > similarity_threshold]
    
    # If no stores meet threshold, use all stores
    if not relevant_stores:
        relevant_stores = store_names

    # Load selected vector stores
    vector_stores = {}
    for name in relevant_stores:
        path = os.path.join(script_dir,"..", "Vector DBs", name)
        vector_stores[name] = FAISS.load_local(path, embeddings, allow_dangerous_deserialization=True)

    # Get results from each store
    all_results = []
    for store_name, store in vector_stores.items():
        results = store.similarity_search_with_score(query+query+query+query+query, k=top_k)
        all_results.extend([(doc, score, store_name) for doc, score in results])

    all_results.sort(key=lambda x: x[1], reverse=True)
    similarity_threshold = 1
    top_results = [(doc, score) for doc, score, store_name in all_results if score >= similarity_threshold]
    # Format context string
    weighted_context = ""
    for doc, score in top_results:
        weighted_context += f"\n{doc.page_content} (relevance: {score})\n\n"
    return weighted_context
