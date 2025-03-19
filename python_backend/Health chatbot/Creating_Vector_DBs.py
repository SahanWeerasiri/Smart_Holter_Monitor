import os
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_community.document_loaders import DirectoryLoader, TextLoader

def create_vector_db_from_datasets():
    script_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    datasets_path = os.path.join(script_dir,"Health chatbot", "resources")
    
    # Load all .md files from the datasets directory using TextLoader with encoding fallback
    loader = DirectoryLoader(
        datasets_path, 
        glob="**/*.md",
        loader_cls=TextLoader,
        loader_kwargs={'autodetect_encoding': True}  # This will attempt to detect the correct encoding
    )
    documents = loader.load()
    
    # Create a single vector store for all documents
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=2000, chunk_overlap=200)
    embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
    
    all_chunks = []
    for doc in documents:
        try:
            # Try to decode content with different encodings if UTF-8 fails
            if isinstance(doc.page_content, bytes):
                encodings = ['utf-8', 'cp1252', 'iso-8859-1']
                for encoding in encodings:
                    try:
                        doc.page_content = doc.page_content.decode(encoding)
                        break
                    except UnicodeDecodeError:
                        continue

            # Split the document into chunks
            print(f"Processing: {doc.metadata.get('source', 'unknown file')}")
            chunks = text_splitter.split_text(doc.page_content)
            all_chunks.extend(chunks)
        except Exception as e:
            print(f"Error processing document: {e}")
            continue
    
    # Check if there are any chunks before creating vector store
    if not all_chunks:
        raise ValueError("No text chunks were generated. Please check if the documents contain valid text content.")
        
    # Create a single vector store
    vector_store = FAISS.from_texts(all_chunks, embeddings)
    print("Created a single vector store for all documents")
    
    # Save the vector store
    vector_dbs_dir = os.path.join(script_dir, "Health chatbot","Vector_DB")
    os.makedirs(vector_dbs_dir, exist_ok=True)
    save_path = os.path.join(vector_dbs_dir)
    vector_store.save_local(save_path)
    print(f"Vector store saved in '{vector_dbs_dir}'")
    
    return vector_store

# Usage
if __name__ == "__main__":
    vector_store = create_vector_db_from_datasets()
