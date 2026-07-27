import os

import bs4
os.environ["USER_AGENT"] = "my-rag-app"
from langchain_community.document_loaders import WebBaseLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_core.vectorstores import InMemoryVectorStore

from langchain_ollama import OllamaEmbeddings, ChatOllama
from langchain_core.prompts import ChatPromptTemplate
from langchain_classic.chains.combine_documents import create_stuff_documents_chain
from langchain_classic.chains import create_retrieval_chain

# 1. Setup Models (Local)
embeddings = OllamaEmbeddings(model="nomic-embed-text")
llm = ChatOllama(model="gemma3:1b") 

# 2. Load & Split Documents
loader = WebBaseLoader(
    web_paths=("https://lilianweng.github.io/posts/2023-06-23-agent/",),
    bs_kwargs=dict(
        parse_only=bs4.SoupStrainer(
            class_=("post-content", "post-title", "post-header")
        )
    ),
)
docs = loader.load()
text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
all_splits = text_splitter.split_documents(docs)

# 3. Embed & Store
vector_store = InMemoryVectorStore(embeddings)
vector_store.add_documents(documents=all_splits)

# 4. Setup Retriever
retriever = vector_store.as_retriever(
    search_type="similarity",      
    search_kwargs={"k": 4}
)

# 5. Create the Chain
SYSTEM = """You are an expert assistant.
Answer *only* from the context between <context></context>;
if the answer isn’t there, say “I don't know.”"""
USER = """<context>\n{context}\n</context>\n\nQuestion: {input}"""

prompt = ChatPromptTemplate.from_messages([("system", SYSTEM), ("user", USER)])
combine_docs_chain = create_stuff_documents_chain(llm, prompt)  
rag_chain = create_retrieval_chain(retriever, combine_docs_chain) 

# 6. Run the Query
question = "What is Chain of thought?"
retrieved_docs = retriever.invoke(question)
print("\n--- WHAT THE RETRIEVER FOUND ---")
for doc in retrieved_docs:
    print(doc.page_content[:200] + "...\n")
print("--------------------------------\n")
result = rag_chain.invoke({"input": question})

print("ANSWER:\n", result["answer"])