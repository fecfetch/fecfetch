# LLM & AI Agent Projects

**What I built while learning to engineer with large language models**

I learn by building. Instead of collecting notes, I worked through the stack one layer at a time and kept every stage as a runnable script I started with calling a model directly, computing embeddings and similarity manually, assembling a retrieval-augmented generation (RAG) pipeline, and finally turning that pipeline into a real application with a UI, external tools and a human in the loop.

The repository contains two things: small experiments that reflect my learning process, and [**Resume Agent**](ResumeAgent/README.md), a Streamlit app that tailors a resume to a job ad without inventing experience. Resume Agent is the project I am most proud of and the best place to start.

## Skills I gained/deepened

| Skill | How I have applied it |
|---|---|
| **Calling LLM APIs** | Sent prompts to Gemini and OpenRouter from Python, and handled keys through arguments, environment variables and a UI instead of hard-coding them |
| **Embeddings and similarity search** | Embedded documents with `nomic-embed-text` and ranked them with NumPy using Euclidean and cosine distance, before touching a vector database |
| **RAG pipelines** | Loaded, cleaned, chunked and indexed documents, then built retrieval chains with grounded prompts that say "I don't know" outside the retrieved context |
| **Local and cloud models** | Ran the same pipeline fully offline with Ollama, on Google models, and as a hybrid with local embeddings and a cloud LLM |
| **Structured LLM output** | Forced a model to return JSON and LaTeX, then parsed both defensively with fallbacks when it disobeyed |
| **Multi-step workflow design** | Built a five-step application with session state, human checkpoints, an external PDF compilation service and a conversational loop |
| **Python and UI** | Wrote a Streamlit interface with caching, a live model catalogue, file downloads and an inline PDF preview |

## How I built up to it

### 1. I started with a single call — [`Tests/first.py`](Tests/first.py)

My first program sends one prompt to Gemini and prints the answer. The key is passed as a command-line argument, so it never ends up in the source.

The point was to see the raw thing: an LLM call is stateless, takes text and returns text. Everything else in this repository is engineering around that.

### 2. I did retrieval by hand before using a framework — [`Tests/manualRag.py`](Tests/manualRag.py), [`Tests/manualRagCosine.py`](Tests/manualRagCosine.py)

Before letting LangChain do it, I embedded ten conference talks with `nomic-embed-text` through the Ollama client and wrote the ranking myself with NumPy: first with Euclidean distance, then with cosine similarity.

Two things I only understood by doing it:

- **Task prefixes are not optional.** `nomic-embed-text` expects `search_document:` on documents and `search_query:` on queries. Without them, retrieval quality drops and nothing tells you why.
- **Distance and similarity are not interchangeable.** Euclid sorts ascending, cosine sorts descending, and cosine ignores vector length, which is usually the behaviour you want for text.

I learned that a vector database is a convenience, not magic. Retrieval is embed, compare, sort.

### 3. I rebuilt it as a real RAG chain — [`Tests/lagchainLocal.py`](Tests/lagchainLocal.py)

Here I used LangChain properly and ran everything locally: loaded a web article, trimmed it to the article body, split it into 1000-character chunks with 200 overlap, embedded them into an in-memory vector store, retrieved the top four chunks, and answered through `create_stuff_documents_chain` and `create_retrieval_chain`.

The prompt only allows answers from the supplied context and otherwise says "I don't know". I learned that grounding is an architectural decision, not a phrase you add at the end.

### 4. I moved the models around — [`Tests/langchainGemini.py`](Tests/langchainGemini.py), [`Tests/langchainOpenRouter.py`](Tests/langchainOpenRouter.py)

I ran the identical chain twice more: once with Google embeddings and Gemini, once hybrid, with local embeddings and generation routed through OpenRouter's OpenAI-compatible endpoint.

Only the model constructors changed. That taught me why the abstraction exists, and that model choice is really an operations decision: embeddings are cheap and repetitive so they can stay on my machine, while generation is the part worth routing to a stronger or free model.

### 5. I turned the pipeline into an application — [`ResumeAgent/`](ResumeAgent/README.md)

The final step was a workflow rather than a script: structured output, human input, an external LaTeX compiler, a conversational mock interview, and a UI that keeps all of it together. I describe the design, the problems I hit and what I learned in the [project README](ResumeAgent/README.md).

## The main project: Resume Agent

I built a Streamlit app that reads a folder of my resumes, finds the two most relevant ones for a job ad, asks me about the requirements I actually have, writes a tailored resume in LaTeX, compiles it to PDF, and then runs a three-question mock interview to recover achievements I forgot to put on paper.

The constraint I designed around: **the model may only use facts I gave it.** Gap analysis can tell me what is missing, but only I can say whether I have it, and the interview turns my spoken answers into evidence on the page.

→ **[Read the full project documentation](ResumeAgent/README.md)**

## Running the experiments

```bash
# Local models
ollama pull nomic-embed-text
ollama pull gemma3:1b

# Dependencies
pip install numpy requests ollama beautifulsoup4 pypdf \
    langchain-classic langchain-community langchain-core langchain-text-splitters \
    langchain-ollama langchain-openai langchain-google-genai google-genai streamlit
```

```bash
python Tests/first.py YOUR_GEMINI_API_KEY   # one API call
python Tests/manualRag.py                   # ranking with Euclidean distance
python Tests/manualRagCosine.py             # ranking with cosine similarity
python Tests/lagchainLocal.py               # fully local RAG chain
python Tests/langchainGemini.py             # RAG on Gemini (prompts for the key)
python Tests/langchainOpenRouter.py         # hybrid RAG via OpenRouter
streamlit run ResumeAgent/resumeAgent.py    # the project
```

The `langchain*` scripts ask for a key with a hidden prompt if the environment variable is missing. Python 3.10 or newer is needed for the app.

## What I learned overall

- **Retrieval quality sets the ceiling.** When a RAG answer is wrong, the retrieved context is usually the reason, not the model. Printing what was retrieved became my first debugging step.
- **Chunking is a design decision.** Chunk size and overlap decide what the model can ever know, and no prompt recovers context that was split apart.
- **A prompt is part of the program.** Structured output needs parsers, fallbacks and escaping, because the model will eventually return something you did not ask for.
- **Agents are workflows with judgement in the middle.** The hard and interesting part is decomposition, state and checkpoints, not the model call itself.
- **For AI features, trust is the product.** Showing sources, keeping the original version and explaining failures mattered more than any prompt tweak.

## Background

These are my applied AI projects from 2026, built alongside my coursework at opencampus.sh; Resume Agent was my final project. I am **Fatih Corumluoglu**, and I am happy to walk through any part of the code or the decisions behind it.
