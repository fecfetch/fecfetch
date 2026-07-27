import bs4
import getpass
import os
os.environ["USER_AGENT"] = "my-rag-app"
from langchain_community.document_loaders import WebBaseLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_core.vectorstores import InMemoryVectorStore
# Remove the old 'langchain_community' imports and use these:
from langchain_ollama import OllamaEmbeddings
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_classic.chains.combine_documents import create_stuff_documents_chain
from langchain_classic.chains import create_retrieval_chain

# Setup API Key
if not os.environ.get("OPENROUTER_API_KEY"):
  os.environ["OPENROUTER_API_KEY"] = getpass.getpass("Enter OpenRouter API key: ")

# 1. Setup Models (Hybrid)
embeddings = OllamaEmbeddings(model="nomic-embed-text") # Local embeddings
llm = ChatOpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.environ.get("OPENROUTER_API_KEY"),
    model="tencent/hy3-preview:free" # Cloud LLM
)

# 2. Load & Split Documents
loader = WebBaseLoader(
    web_paths=("https://lilianweng.github.io/posts/2023-06-23-agent/",),
    bs_kwargs=dict(parse_only=bs4.SoupStrainer(class_=("post-content", "post-title", "post-header")))
)
all_splits = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200).split_documents(loader.load())

# 3. Embed & Store
vector_store = InMemoryVectorStore(embeddings)
vector_store.add_documents(documents=all_splits)

# 4. Setup Retriever
retriever = vector_store.as_retriever(search_kwargs={"k": 4})

# 5. Create the Chain
SYSTEM = """You are an expert assistant. Answer *only* from the context between <context></context>; if the answer isn’t there, say “I don't know.”"""
USER = """<context>\n{context}\n</context>\n\nQuestion: {input}"""
prompt = ChatPromptTemplate.from_messages([("system", SYSTEM), ("user", USER)])
rag_chain = create_retrieval_chain(retriever, create_stuff_documents_chain(llm, prompt)) 

# 6. Run the Query
question = "What is Task Decomposition?"
retrieved_docs = retriever.invoke(question)
print("\n--- WHAT THE RETRIEVER FOUND ---")
for doc in retrieved_docs:
    print(doc.page_content[:200] + "...\n")
print("--------------------------------\n")
result = rag_chain.invoke({"input": question})

print("ANSWER:\n", result["answer"])