# Resume Agent

**An AI app that tailors the given resume to a job ad without inventing experience and then interviews me to find the achievements I forgot to write down.**

I built this as a Streamlit application. It reads a folder of my existing resumes, matches them against a job advertisement, asks me about the requirements I genuinely have, writes a tailored resume in LaTeX, compiles it into a PDF, and runs a short mock interview that feeds new facts back into the document.

**Stack:** Python, Streamlit, LangChain, Ollama, OpenRouter, LaTeX
**Status:** working prototype, runs end to end on free models

---

## Why I built it

Applying for jobs meant rewriting my CV over and over, and my material was scattered across old versions. One resume had the project, another had the metric, a third had the right phrasing.

I did not want a tool that invents experinece. I wanted a tool that finds the relevant parts of my real history, shows me what the job asks for that I have not evidenced, and asks me directly instead of guessing.

It was also the natural next step after building RAG experiments. I used the same retrieval ideas, but inside a workflow with state, an external tool and a human decision at the centre.

## What it does

1. **Load** every PDF, TXT or MD resume in a folder and index it locally.
2. **Match** the job ad against that index and select the two most relevant resumes.
3. **Compare** them with the ad and list the requirements they do not evidence.
4. **Ask** me which of those gaps I actually have, and let me describe the real experience.
5. **Write** a tailored resume in LaTeX from my own material, compile it to PDF, and offer downloads.
6. **Interview** me with three hiring-manager questions and merge anything new I mention back into the resume.

```text
resumes/  ──►  chunk  ──►  embed locally  ──►  vector store
                                                    │
job ad  ────────────────────────────────────────────┤
                                                    ▼
                                          top 2 relevant resumes
                                                    │
                                                    ▼
                                    skill gaps (LLM, JSON output)
                                                    │
                                    I confirm and describe what I have
                                                    │
                                                    ▼
                                   tailored LaTeX resume  ──►  PDF
                                                    │
                                                    ▼
                                     mock interview, 3 questions
                                                    │
                                                    ▼
                                new facts merged back in  ──►  enhanced PDF
```

## How it works

### 1. Loading and retrieval

I load documents with `PyPDFLoader` or `TextLoader`, split each resume into 600-character chunks with 80 characters of overlap, and embed them with `nomic-embed-text` running locally in Ollama. The vectors live in a LangChain `InMemoryVectorStore` for the session.

For a job ad I retrieve the 20 most similar chunks, then **average the scores per source file** and keep the two best resumes. I chose this after noticing that embedding a whole resume as one vector diluted its strongest paragraph, while retrieving loose chunks gave the model fragments without context. Ranking chunks and returning complete documents solved both.

### 2. Gap analysis with a human checkpoint

The model receives the ad and the selected resumes and must return only a JSON array of specific missing requirements, not vague areas. I strip markdown fences if it adds them, and fall back to extracting quoted strings if the JSON is broken.

The gaps appear as badges. I select the ones I have, describe them in a sentence or two, and everything I skip is never written into the resume. This separation is the core of the design: **the model can say what is missing, but only I can say what is true.**

### 3. Generating the resume

The generation prompt gets the ad, the full text of the selected resumes and my gap answers, with strict instructions: use only these facts, output only valid LaTeX, no commentary. I use a clean `article`-class template with 0.75in margins so the result looks consistent regardless of which model wrote it.

The LaTeX is compiled to PDF through the public `latex.ytotech.com` API with a 30-second timeout. I can download the `.tex` or the `.pdf` and preview the PDF inline. When compilation fails, the app shows the LaTeX for Overleaf instead of failing silently.

### 4. Mock interview and resume enhancement

A hiring manager persona asks three questions, one at a time, based on the ad and the tailored resume. When the interview ends, the full transcript goes back to the model with one job: find skills, metrics or achievements I mentioned that the resume does not show, and patch them into the LaTeX without breaking it or inventing anything.

I get a plain-language summary of the changes ("added a bullet about reducing query time by 40%"), an enhanced resume tab with a new PDF, and the original version kept beside it. I can also end the interview early; the partial transcript is still analysed.

### 5. The app

Everything is in one file because the project is about workflow design, and keeping the prompts next to the code that sends them makes the whole pipeline readable from top to bottom.

| Piece | Responsibility |
|---|---|
| `load_resumes`, `build_vector_store` | Read files, chunk, embed, index |
| `retrieve_top_resumes` | Chunk search, score aggregation, top two documents |
| `identify_gaps` | JSON gap list with a defensive parser |
| `generate_resume` | Tailored LaTeX from resumes and my answers |
| `get_interviewer_response` | Next question from the transcript |
| `enhance_resume_with_interview` | Merge new facts, return changes and updated LaTeX |
| `compile_latex_to_pdf`, `render_pdf` | PDF build and inline preview |
| `fetch_openrouter_models`, `estimate_intelligence` | Live model catalogue and dropdown ordering |

State lives in a single defaults dictionary seeded into `st.session_state`: step, documents, vector store, gaps, answers, generated files and transcript. "Start Over" resets all of it.

## Problems I ran into

**The model invented experience.** My first version could quietly add skills I did not have. I fixed it in the workflow so that generation may only use supplied sources, missing requirements become questions for me, and the interview is the only place new facts can enter, from my own answers. The prompts say "do not invent", but the design is what actually prevents it.

**Retrieval sometimes chose the wrong resume.** Searching whole documents ranked the best-matching resume poorly if the rest of the resume was unrelated. Moving to chunk-level search and averaging scores per file made the selection far more predictable.

**Free models failed under load.** 504s from the provider looked like a crash to the user. I now fetch the model catalogue with an 8-second timeout and a one-hour cache, filter by price, and turn provider errors into an explanation with a suggestion to go back and pick another model.

**The output was not always valid LaTeX or JSON.** Models wrapped it in markdown fences, added commentary, or broke the format. I strip fences, parse gaps with a regex fallback, use an explicit separator between the improvement summary and the document, and instruct the model to escape `%`, `&`, `$` and `_` from my answers so my own text cannot corrupt the file.

**PDF compilation failed on some generations.** The compile call has a timeout and returns nothing on failure, so the app falls back to the `.tex` with an Overleaf hint. The original tailored version is always kept, so a bad enhancement cannot destroy a good resume.

## What I learned

- **Retrieval quality sets the ceiling.** Most weak answers were retrieval failures, not generation failures. Printing retrieved chunks was the habit that made this visible.
- **Prompts are part of the program.** Structured output only works if you own the parser, the fallbacks and the escaping. Asking nicely is not a type system.
- **Human checkpoints make AI output trustworthy.** Letting the model propose and the person confirm was more effective than any instruction to "be accurate".
- **Model choice is engineering, not ideology.** Local embeddings plus a free cloud model made this cheap to run and good enough to use. The app keeps the model swappable because availability and quality change weekly.
- **UX is part of the AI feature.** Model picker, progress states, downloads, the "what changed" summary and the preserved original did more for trust than a better prompt.

## Tech stack

| Layer | Tools | Why |
|---|---|---|
| Interface | Streamlit | Fast enough to build a five-step flow with chat and downloads in one file |
| Orchestration | LangChain core, community, text splitters | Document loading, chunking, `InMemoryVectorStore` |
| Embeddings | Ollama + `nomic-embed-text` | Local, free, private, no key required |
| Generation | OpenRouter via `langchain-openai` | One API for many models, including free ones |
| Documents | pypdf, LaTeX | Text extraction and clean, editable PDF output |
| Tools | `requests`, `latex.ytotech.com` | Model catalogue and PDF compilation over HTTP |

## Run it

**Requirements:** Python 3.10+, Ollama, an OpenRouter API key.

```bash
ollama pull nomic-embed-text
ollama serve

pip install streamlit requests pypdf \
    langchain-community langchain-text-splitters langchain-core \
    langchain-ollama langchain-openai

streamlit run ResumeAgent/resumeAgent.py
```

In the app: paste the OpenRouter key, point it at a resume folder (the repository includes [`SampleResume/`](../SampleResume) for a first run), load the resumes, then paste a job ad. The key stays in session state and is never written to disk or logged.

**Defaults I tuned:** 600/80 chunking, 20 chunks retrieved, two resumes shortlisted, temperature 0.3, three interview questions, 30-second PDF timeout.

## Limitations and next steps

This is a prototype, and I know where its edges are:

- **Nothing persists.** A page reload loses the session and generated files. Next: save sessions and outputs to SQLite.
- **No automated tests.** The fragile parts are the JSON parser, the LaTeX cleanup and the retrieval aggregation. Next: pytest with a fake LLM so those paths are covered without API calls.
- **The model ranking is a heuristic.** `estimate_intelligence` is a hand-written pattern list used only to order a dropdown, not a benchmark. Next: use provider metadata, or let me pin favourites.
- **Resume data leaves my machine.** Selected resumes and the ad go to OpenRouter, and the generated LaTeX goes to a public compiler. Next: an option to generate with a local model via Ollama, and a warning in the UI for confidential documents.
- **Scanned PDFs produce nothing.** Without a text layer there is nothing to embed. Next: OCR or an explicit message.
- **The interview is fixed at three questions** and gives no feedback on answer quality; it exists to recover facts, not to assess me. Next: adaptive length based on the resume's gaps.

## Context

I built this as my final project for the applied AI programme at opencampus.sh (2026), and it is the piece I use to explain how I work: start from a real problem, keep the model on a leash, and design the checkpoints that make the output something I can trust.

**Fatih Corumluoglu** — [back to the project overview](../README.md)
