"""
Resume Agent — AI-powered resume tailoring with RAG
----------------------------------------------------
Workflow:
  1. Load resumes from a local folder (PDF / TXT / MD)
  2. User pastes a job ad
  3. App retrieves the 2 most relevant resumes via vector similarity
  4. LLM identifies skill gaps (things in the job ad not in those resumes)
  5. App asks the user about each gap
  6. LLM writes a tailored resume
"""

import os
import re
import getpass
import requests
from pathlib import Path
from collections import defaultdict

import streamlit as st

# ── LangChain imports ──────────────────────────────────────────────────────────
from langchain_community.document_loaders import PyPDFLoader, TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_core.vectorstores import InMemoryVectorStore
from langchain_core.documents import Document
from langchain_ollama import OllamaEmbeddings
from langchain_openai import ChatOpenAI

# ══════════════════════════════════════════════════════════════════════════════
# Page config & CSS
# ══════════════════════════════════════════════════════════════════════════════

st.set_page_config(
    page_title="Resume Agent",
    page_icon="📄",
    layout="wide",
    initial_sidebar_state="collapsed",
)

st.markdown("""
<style>
@import url('https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=DM+Sans:wght@300;400;500;600&display=swap');

html, body, [class*="css"] {
    font-family: 'DM Sans', sans-serif;
}
h1, h2, h3, .headline {
    font-family: 'DM Serif Display', serif;
}

/* Stepper bar */
.stepper {
    display: flex;
    gap: 0;
    margin-bottom: 2rem;
    border-radius: 12px;
    overflow: hidden;
    border: 1px solid #e2e2e2;
}
.step {
    flex: 1;
    padding: 0.6rem 1rem;
    font-size: 0.8rem;
    font-weight: 500;
    text-align: center;
    background: #f7f7f5;
    color: #aaa;
    letter-spacing: 0.04em;
    border-right: 1px solid #e2e2e2;
}
.step:last-child { border-right: none; }
.step.active   { background: #1a1a1a; color: #fff; }
.step.done     { background: #e8f5e9; color: #2e7d32; }

/* Cards */
.resume-card {
    background: #fff;
    border: 1px solid #e2e2e2;
    border-radius: 12px;
    padding: 1.2rem 1.5rem;
    margin-bottom: 1rem;
}
.resume-card h4 { margin: 0 0 0.3rem 0; font-size: 1rem; }
.resume-card p  { margin: 0; font-size: 0.85rem; color: #555; }

/* Gap badge */
.gap-badge {
    display: inline-block;
    background: #fff3e0;
    color: #e65100;
    border: 1px solid #ffcc80;
    border-radius: 20px;
    padding: 0.15rem 0.7rem;
    font-size: 0.78rem;
    font-weight: 500;
    margin: 0.2rem;
}

/* Generated resume box */
.resume-output {
    background: #fafafa;
    border: 1px solid #ddd;
    border-radius: 12px;
    padding: 2rem 2.5rem;
    font-family: 'DM Sans', sans-serif;
    line-height: 1.7;
    white-space: pre-wrap;
}
</style>
""", unsafe_allow_html=True)


# ══════════════════════════════════════════════════════════════════════════════
# Session state initialisation
# ══════════════════════════════════════════════════════════════════════════════

DEFAULTS = {
    "step": 1,                  
    "vector_store": None,
    "resume_docs": {},           
    "selected_resumes": [],      
    "job_ad": "",
    "gaps": [],                  # list of gap strings identified by LLM
    "selected_gaps": [],         # list of gap strings user has experience in
    "gap_answers": {},           
    "final_resume": "",
    "final_pdf": None,           # compiled PDF bytes of original resume
    "final_resume_enhanced": "", # resume updated after mock interview
    "final_pdf_enhanced": None,  # compiled PDF bytes of enhanced resume
    "improvements_made": "",     # summary of improvements made after interview
    "interview_messages": [],    # list of dict {"role": "user"/"assistant", "content": ""}
    "interview_started": False,
    "interview_question_count": 0,
    "interview_complete": False,
    "api_key": "",
    "model_name": "tencent/hy3-preview:free",
    "resumes_folder": str(Path.home() / "resumes"),
}
for k, v in DEFAULTS.items():
    if k not in st.session_state:
        st.session_state[k] = v


# ══════════════════════════════════════════════════════════════════════════════
# Helpers
# ══════════════════════════════════════════════════════════════════════════════

@st.cache_data(ttl=3600, show_spinner=False)
def fetch_openrouter_models() -> list[dict]:
    """Fetch all available models from OpenRouter with a timeout fallback."""
    try:
        response = requests.get("https://openrouter.ai/api/v1/models", timeout=8)
        if response.status_code == 200:
            return response.json().get("data", [])
    except Exception:
        pass
    return []


def estimate_intelligence(model_id: str) -> int:
    """Assign an estimated intelligence score to rank models in the UI."""
    model_id = model_id.lower()
    rankings = [
        ("claude-3.5-sonnet", 100),
        ("gpt-4o", 95),
        ("gemini-2.5-pro", 92),
        ("gemini-2-pro", 92),
        ("gemini-1.5-pro", 88),
        ("llama-3.3-70b", 85),
        ("deepseek-chat", 82),
        ("deepseek-coder", 82),
        ("qwen-2.5-coder-32b", 80),
        ("qwen-2.5-72b", 80),
        ("llama-3.1-70b", 78),
        ("gemini-2.5-flash", 75),
        ("gemini-2-flash", 75),
        ("gemini-flash-1.5", 72),
        ("gemma-4-31b", 70),
        ("gemma-4-26b", 68),
        ("gemma-2-27b", 65),
        ("llama-3.3-8b", 60),
        ("llama-3.1-8b", 58),
        ("gemma-2-9b", 55),
        ("gemma-4", 50),
        ("free", 5), # free model router
    ]
    for pattern, score in rankings:
        if pattern in model_id:
            return score
    return 10  # Default score for unknown models


@st.cache_resource(show_spinner=False)
def build_embeddings():
    return OllamaEmbeddings(model="nomic-embed-text")


def get_llm(api_key: str, model_name: str) -> ChatOpenAI:
    return ChatOpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key=api_key,
        model=model_name,
        temperature=0.3,
    )


def load_resumes(folder: str) -> dict[str, str]:
    """Return {filename: full_text} for every resume found in `folder`."""
    folder_path = Path(folder)
    if not folder_path.exists():
        return {}

    docs: dict[str, str] = {}
    for fp in sorted(folder_path.iterdir()):
        if fp.suffix.lower() == ".pdf":
            loader = PyPDFLoader(str(fp))
            pages = loader.load()
            docs[fp.name] = "\n".join(p.page_content for p in pages)
        elif fp.suffix.lower() in {".txt", ".md"}:
            loader = TextLoader(str(fp), encoding="utf-8")
            pages = loader.load()
            docs[fp.name] = pages[0].page_content if pages else ""

    return docs


def build_vector_store(resume_docs: dict[str, str]) -> InMemoryVectorStore:
    """Chunk each resume and embed into an in-memory vector store."""
    embeddings = build_embeddings()
    splitter = RecursiveCharacterTextSplitter(chunk_size=600, chunk_overlap=80)
    all_chunks: list[Document] = []

    for filename, text in resume_docs.items():
        chunks = splitter.create_documents([text], metadatas=[{"source": filename}])
        all_chunks.extend(chunks)

    vs = InMemoryVectorStore(embeddings)
    vs.add_documents(all_chunks)
    return vs


def retrieve_top_resumes(
    vector_store: InMemoryVectorStore,
    job_ad: str,
    k_chunks: int = 20,
    top_n: int = 2,
) -> list[tuple[str, float]]:
    """
    Do a similarity search, aggregate chunk scores by source file,
    and return the `top_n` (filename, avg_score) pairs.
    """
    results = vector_store.similarity_search_with_score(job_ad, k=k_chunks)

    scores: dict[str, list[float]] = defaultdict(list)
    for doc, score in results:
        src = doc.metadata.get("source", "unknown")
        scores[src].append(score)

    aggregated = {src: sum(s) / len(s) for src, s in scores.items()}
    ranked = sorted(aggregated.items(), key=lambda x: x[1], reverse=True)
    return ranked[:top_n]


def identify_gaps(llm: ChatOpenAI, job_ad: str, resume_texts: list[str]) -> list[str]:
    """
    Ask the LLM to list skills / experience areas mentioned in the job ad
    that are NOT present in the provided resumes.
    Returns a list of gap strings.
    """
    combined_resumes = "\n\n---\n\n".join(resume_texts)
    prompt = f"""You are a career coach analysing a job advertisement against a candidate's resumes.

JOB ADVERTISEMENT:
{job_ad}

CANDIDATE'S EXISTING RESUMES:
{combined_resumes}

Task: List every skill, technology, qualification, or experience area that the job ad explicitly or implicitly requires but that is NOT mentioned or evidenced anywhere in the candidate's resumes.

Rules:
- Only list genuine gaps — things the job requires that are absent from the resumes.
- Be specific (e.g. "experience with Kubernetes" rather than "cloud experience").
- Return ONLY a JSON array of short strings. Example: ["Kubernetes", "French language", "PMP certification"]
- If there are no gaps, return an empty array: []
- Do not include any explanation outside the JSON array.
"""
    response = llm.invoke(prompt)
    raw = response.content.strip()

    # Strip markdown fences if present
    raw = re.sub(r"^```[a-z]*\n?", "", raw)
    raw = re.sub(r"\n?```$", "", raw)

    import json
    try:
        gaps = json.loads(raw)
        return [g.strip() for g in gaps if isinstance(g, str) and g.strip()]
    except Exception:
        # Fallback: extract quoted strings
        return re.findall(r'"([^"]+)"', raw)


def generate_resume(
    llm: ChatOpenAI,
    job_ad: str,
    base_resume_texts: list[str],
    gap_answers: dict[str, str],
) -> str:
    """Generate a tailored resume using the job ad, base resumes, and gap answers."""
    gap_section = ""
    if gap_answers:
        lines = []
        for gap, answer in gap_answers.items():
            if answer.strip():
                lines.append(f"- {gap}: {answer}")
        if lines:
            gap_section = (
                "\n\nADDITIONAL EXPERIENCE PROVIDED BY THE CANDIDATE:\n"
                + "\n".join(lines)
            )

    combined_resumes = "\n\n---\n\n".join(base_resume_texts)

    prompt = f"""You are an expert resume writer. Create a polished, tailored resume in valid LaTeX format.

JOB ADVERTISEMENT:
{job_ad}

CANDIDATE'S EXISTING RESUMES (use these as the sole factual source):
{combined_resumes}
{gap_section}

Instructions:
1. Write a professional resume optimised for this specific job.
2. Use ONLY facts drawn from the existing resumes and the additional experience provided. Do NOT invent or embellish any details.
3. Output ONLY valid LaTeX code. Do NOT wrap it in markdown code block fences (like ```latex or ```). Do not include any introductory or concluding text.
4. Keep the styling clean, modern, and minimal. Use the standard article class.
5. Use this clean template structure as a guide:
\\documentclass[10pt,letterpaper]{{article}}
\\usepackage[margin=0.75in]{{geometry}}
\\usepackage[utf8]{{inputenc}}
\\usepackage{{hyperref}}
\\usepackage{{enumitem}}
\\usepackage{{titlesec}}

\\titleformat{{\\section}}{{\\large\\bfseries}}{{}}{{0em}}{{}}[\\titlerule]
\\titlespacing*{{\\section}}{{0pt}}{{8pt}}{{4pt}}

\\begin{{document}}
\\pagestyle{{empty}}

% Header
\\begin{{center}}
    {{\\LARGE \\bf [Candidate Name]}} \\\\
    [Email] | [Phone] | [LinkedIn / GitHub]
\\end{{center}}

\\section*{{Professional Summary}}
[Tailored professional summary]

\\section*{{Experience}}
% For each job:
\\noindent \\textbf{{[Job Title]}} \\hfill [Dates] \\\\
\\textit{{[Company Name]}} \\hfill [Location]
\\begin{{itemize}}[noitemsep,topsep=2pt,parsep=2pt,partopsep=0pt,leftmargin=1.5em]
    \\item [Achievement bullet point]
    \\item [Achievement bullet point]
\\end{{itemize}}

\\section*{{Skills}}
\\begin{{itemize}}[noitemsep,topsep=2pt,parsep=2pt,partopsep=0pt,leftmargin=1.5em]
    \\item \\textbf{{Languages/Tools}}: [List skills]
\\end{{itemize}}

\\section*{{Education}}
\\noindent \\textbf{{[Degree]}} \\hfill [Graduation Date] \\\\
\\textit{{[Institution]}} \\hfill [Location]

\\end{{document}}
"""
    response = llm.invoke(prompt)
    raw = response.content.strip()
    
    # Strip markdown block fences if model generates them
    raw = re.sub(r"^```[a-z]*\n?", "", raw)
    raw = re.sub(r"\n?```$", "", raw)
    return raw.strip()


def get_interviewer_response(
    llm: ChatOpenAI,
    job_ad: str,
    current_resume: str,
    chat_history: list
) -> str:
    """Ask the next interview question based on the job, resume, and chat history."""
    history_str = ""
    for msg in chat_history:
        role = "Candidate" if msg["role"] == "user" else "Interviewer"
        history_str += f"{role}: {msg['content']}\n"
        
    prompt = f"""You are a professional hiring manager conducting a mock interview for the following position.

JOB ADVERTISEMENT:
{job_ad}

CANDIDATE'S CURRENT TAILORED RESUME:
{current_resume}

CONVERSATION SO FAR:
{history_str}

Task: Ask the next interview question. 
Rules:
- Be realistic, professional, and slightly challenging.
- Focus on skills required in the job ad, especially checking how the candidate would apply their experience.
- Do NOT ask multiple questions at once. Ask exactly one single question.
- Do NOT include any meta-commentary, just output the interviewer's direct spoken response.
"""
    response = llm.invoke(prompt)
    return response.content.strip()


def enhance_resume_with_interview(
    llm: ChatOpenAI,
    job_ad: str,
    current_resume: str,
    chat_history: list
) -> tuple[str, str]:
    """Analyze the interview transcript, integrate new facts into the resume, and list improvements."""
    history_str = ""
    for msg in chat_history:
        role = "Candidate" if msg["role"] == "user" else "Interviewer"
        history_str += f"{role}: {msg['content']}\n"

    prompt = f"""You are an expert resume writer and career coach.
You have a candidate's current resume (written in LaTeX) and the transcript of a mock interview they just completed.

JOB ADVERTISEMENT:
{job_ad}

CURRENT RESUME (LaTeX):
{current_resume}

MOCK INTERVIEW TRANSCRIPT:
{history_str}

Task:
1. Analyze the transcript to find specific skills, achievements, technologies, metrics, or experiences that the candidate mentioned during the interview but are NOT explicitly or fully represented in their current resume.
2. Update the LaTeX code of the current resume to integrate these new facts. Do not invent any facts; only use information from the candidate's existing resume and their transcript answers.
3. Maintain valid LaTeX syntax and do not break the document structure. Ensure all special LaTeX characters (like %, &, $, _) in user answers are properly escaped if needed (e.g. use \\% instead of %).
4. Output a summary of the improvements you made, followed by a separator "=== RESUME ===", followed by the complete, updated LaTeX resume code. Do not wrap the LaTeX code in markdown blocks.

Example Output format:
- Added bullet point about 40% database optimization using Redis under software engineer role.
- Included AWS Lambda in the Skills section.
=== RESUME ===
[Complete updated LaTeX code here]
"""
    response = llm.invoke(prompt)
    content = response.content.strip()
    
    parts = content.split("=== RESUME ===")
    if len(parts) >= 2:
        improvements = parts[0].strip()
        enhanced_resume = "=== RESUME ===".join(parts[1:]).strip()
    else:
        improvements = "Enhanced resume sections based on mock interview details."
        enhanced_resume = content
        
    # Strip markdown block fences if generated
    enhanced_resume = re.sub(r"^```[a-z]*\n?", "", enhanced_resume)
    enhanced_resume = re.sub(r"\n?```$", "", enhanced_resume)
    
    return enhanced_resume.strip(), improvements


def compile_latex_to_pdf(latex_code: str) -> bytes | None:
    """Compile LaTeX source text into PDF bytes using the public latex.ytotech.com API."""
    payload = {
        "compiler": "pdflatex",
        "resources": [
            {
                "main": True,
                "content": latex_code
            }
        ]
    }
    try:
        response = requests.post("https://latex.ytotech.com/builds/sync", json=payload, timeout=30)
        if response.status_code in (200, 201):
            return response.content
    except Exception:
        pass
    return None


def render_pdf(pdf_bytes: bytes):
    """Render PDF bytes in an HTML iframe within Streamlit."""
    import base64
    base64_pdf = base64.b64encode(pdf_bytes).decode('utf-8')
    pdf_display = f'<iframe src="data:application/pdf;base64,{base64_pdf}" width="100%" height="800" type="application/pdf"></iframe>'
    st.markdown(pdf_display, unsafe_allow_html=True)


# ══════════════════════════════════════════════════════════════════════════════
# Stepper UI
# ══════════════════════════════════════════════════════════════════════════════

STEP_LABELS = ["1 · Setup", "2 · Job Ad", "3 · Gaps", "4 · Resume", "5 · Practice"]


def render_stepper(current: int):
    html = '<div class="stepper">'
    for i, label in enumerate(STEP_LABELS, start=1):
        cls = "active" if i == current else ("done" if i < current else "step")
        html += f'<div class="step {cls}">{label}</div>'
    html += "</div>"
    st.markdown(html, unsafe_allow_html=True)


# ══════════════════════════════════════════════════════════════════════════════
# Main app
# ══════════════════════════════════════════════════════════════════════════════

st.markdown("<h1 style='margin-bottom:0.1rem'>📄 Resume Agent</h1>", unsafe_allow_html=True)
st.markdown("<p style='color:#777;margin-top:0;margin-bottom:1.5rem'>AI-powered resume tailoring · powered by RAG + OpenRouter</p>", unsafe_allow_html=True)

render_stepper(st.session_state.step)

# ─────────────────────────────────────────────────────────────────────────────
# STEP 1 — Setup
# ─────────────────────────────────────────────────────────────────────────────
if st.session_state.step == 1:
    st.subheader("Setup")

    col1, col2 = st.columns([3, 2])
    with col1:
        api_key = st.text_input(
            "OpenRouter API key",
            value=st.session_state.api_key,
            type="password",
            placeholder="sk-or-...",
        )
        folder = st.text_input(
            "Resumes folder path",
            value=st.session_state.resumes_folder,
            placeholder="/home/you/resumes",
        )
        
        # Fetch models dynamically
        all_models = fetch_openrouter_models()
        if not all_models:
            # Fallback list if fetching fails
            fallback_models = [
                {"id": "tencent/hy3-preview:free", "name": "Tencent: Hunyuan 3 Preview (free)", "pricing": {"prompt": "0", "completion": "0"}, "context_length": 32000},
                {"id": "meta-llama/llama-3.3-70b-instruct:free", "name": "Meta: Llama 3.3 70B Instruct (free)", "pricing": {"prompt": "0", "completion": "0"}, "context_length": 32000},
                {"id": "google/gemini-2.5-flash:free", "name": "Google: Gemini 2.5 Flash (free)", "pricing": {"prompt": "0", "completion": "0"}, "context_length": 1048576},
                {"id": "qwen/qwen-2.5-coder-32b-instruct:free", "name": "Qwen: Qwen 2.5 Coder 32B (free)", "pricing": {"prompt": "0", "completion": "0"}, "context_length": 32000},
                {"id": "anthropic/claude-3.5-sonnet", "name": "Anthropic: Claude 3.5 Sonnet", "pricing": {"prompt": "0.000003", "completion": "0.000015"}, "context_length": 200000},
                {"id": "openai/gpt-4o", "name": "OpenAI: GPT-4o", "pricing": {"prompt": "0.0000025", "completion": "0.00001"}, "context_length": 128000},
                {"id": "google/gemini-2.5-pro", "name": "Google: Gemini 2.5 Pro", "pricing": {"prompt": "0.00000125", "completion": "0.000005"}, "context_length": 1048576},
            ]
            all_models = fallback_models

        # Filter for free/paid models
        only_free = st.checkbox("Only show free models", value=True)
        
        filtered_models = []
        for m in all_models:
            pricing = m.get("pricing", {})
            prompt_cost = float(pricing.get("prompt", 0))
            completion_cost = float(pricing.get("completion", 0))
            is_free = (prompt_cost == 0 and completion_cost == 0)
            
            if only_free:
                if is_free:
                    filtered_models.append(m)
            else:
                filtered_models.append(m)

        # Sort models by intelligence (descending)
        filtered_models.sort(key=lambda x: estimate_intelligence(x["id"]), reverse=True)
        
        # Create selectbox options
        model_options = []
        model_ids = []
        for m in filtered_models:
            ctx = m.get("context_length", 0)
            ctx_formatted = f"{ctx:,} tokens" if ctx else "unknown context"
            pricing = m.get("pricing", {})
            prompt_cost = float(pricing.get("prompt", 0))
            
            cost_str = "Free" if (prompt_cost == 0) else f"${prompt_cost * 1e6:.2f}/M tokens"
            label = f"{m.get('name')} ({ctx_formatted} · {cost_str})"
            model_options.append(label)
            model_ids.append(m.get("id"))
            
        # Get index of current model in options
        current_model = st.session_state.model_name
        default_idx = 0
        if current_model in model_ids:
            default_idx = model_ids.index(current_model)
        elif "tencent/hy3-preview:free" in model_ids:
            default_idx = model_ids.index("tencent/hy3-preview:free")
            
        selected_model_label = st.selectbox(
            "Select OpenRouter Model",
            options=model_options,
            index=default_idx if default_idx < len(model_options) else 0
        )
        
        # Find matching model ID
        selected_model_id = model_ids[model_options.index(selected_model_label)]

    with col2:
        st.info(
            "📂 Put your resumes in the folder above.\n\n"
            "Supported formats: **PDF**, **TXT**, **MD**\n\n"
            "You need **Ollama** running locally with the `nomic-embed-text` model "
            "for embeddings, and an **OpenRouter** key for the language model."
        )

    if st.button("Load Resumes →", type="primary"):
        if not api_key:
            st.error("Please enter your OpenRouter API key.")
        else:
            with st.spinner("Loading and embedding resumes…"):
                docs = load_resumes(folder)
                if not docs:
                    st.error(f"No supported resumes found in `{folder}`. "
                             "Add .pdf / .txt / .md files and try again.")
                else:
                    vs = build_vector_store(docs)
                    st.session_state.api_key = api_key
                    st.session_state.model_name = selected_model_id
                    st.session_state.resumes_folder = folder
                    st.session_state.resume_docs = docs
                    st.session_state.vector_store = vs
                    st.success(f"Loaded **{len(docs)}** resume(s): {', '.join(docs.keys())}")
                    st.session_state.step = 2
                    st.rerun()


# ─────────────────────────────────────────────────────────────────────────────
# STEP 2 — Job Ad
# ─────────────────────────────────────────────────────────────────────────────
elif st.session_state.step == 2:
    st.subheader("Paste the Job Advertisement")

    job_ad = st.text_area(
        "Job ad text",
        value=st.session_state.job_ad,
        height=350,
        placeholder="Paste the full job advertisement here…",
    )

    col_back, col_next = st.columns([1, 5])
    with col_back:
        if st.button("← Back"):
            st.session_state.step = 1
            st.rerun()
    with col_next:
        if st.button("Analyse →", type="primary"):
            if len(job_ad.strip()) < 50:
                st.error("Please paste a complete job advertisement.")
            else:
                with st.spinner("Finding the most relevant resumes…"):
                    top = retrieve_top_resumes(
                        st.session_state.vector_store, job_ad
                    )
                    selected = [
                        (name, score, st.session_state.resume_docs[name])
                        for name, score in top
                        if name in st.session_state.resume_docs
                    ]
                    st.session_state.selected_resumes = selected
                    st.session_state.job_ad = job_ad

                try:
                    with st.spinner("Identifying skill gaps…"):
                        llm = get_llm(st.session_state.api_key, st.session_state.model_name)
                        resume_texts = [text for _, _, text in selected]
                        gaps = identify_gaps(llm, job_ad, resume_texts)
                        st.session_state.gaps = gaps
                        st.session_state.gap_answers = {g: "" for g in gaps}

                    st.session_state.step = 3
                    st.rerun()
                except Exception as e:
                    st.error(
                        f"⚠️ OpenRouter Error: {str(e)}\n\n"
                        "This is often a temporary provider issue or a 504 Gateway Timeout. "
                        "Please go back to Step 1 (Setup) and try a different model."
                    )


# ─────────────────────────────────────────────────────────────────────────────
# STEP 3 — Gap Q&A
# ─────────────────────────────────────────────────────────────────────────────
elif st.session_state.step == 3:
    st.subheader("Selected Resumes & Skill Gaps")

    # Show selected resumes
    st.markdown("**Top 2 most relevant resumes for this role:**")
    for name, score, _ in st.session_state.selected_resumes:
        with st.expander(f"📄 {name}  —  relevance score: {score:.3f}"):
            st.text(st.session_state.resume_docs.get(name, "")[:3000] + "…")

    st.divider()

    gaps = st.session_state.gaps
    if not gaps:
        st.success("✅ No skill gaps detected — your resumes already cover everything in the job ad!")
    else:
        st.markdown(
            "**The following requirements appear in the job ad but not in your resumes.**"
        )

        # Render gap badges
        badge_html = "".join(f'<span class="gap-badge">{g}</span>' for g in gaps)
        st.markdown(badge_html, unsafe_allow_html=True)
        st.markdown("")

        # Let user select which gaps they actually have experience with
        selected_gaps = st.multiselect(
            "Select any requirements you have experience in (or leave empty to skip):",
            options=gaps,
            default=st.session_state.selected_gaps,
        )
        st.session_state.selected_gaps = selected_gaps

        st.markdown("")

        # Input ONLY for selected gaps
        for gap in selected_gaps:
            answer = st.text_area(
                f"Your experience with: **{gap}**",
                value=st.session_state.gap_answers.get(gap, ""),
                height=80,
                key=f"gap_{gap}",
                placeholder="Describe any relevant experience...",
            )
            st.session_state.gap_answers[gap] = answer

    st.divider()
    col_back, col_next = st.columns([1, 5])
    with col_back:
        if st.button("← Back"):
            st.session_state.step = 2
            st.rerun()
    with col_next:
        if st.button("Generate Resume →", type="primary"):
            try:
                with st.spinner("Writing your tailored resume…"):
                    llm = get_llm(st.session_state.api_key, st.session_state.model_name)
                    resume_texts = [text for _, _, text in st.session_state.selected_resumes]
                    
                    # Filter gap answers to only include user's selected gaps
                    filtered_gap_answers = {
                        gap: st.session_state.gap_answers.get(gap, "")
                        for gap in st.session_state.selected_gaps
                        if st.session_state.gap_answers.get(gap, "").strip()
                    }
                    
                    final = generate_resume(
                        llm,
                        st.session_state.job_ad,
                        resume_texts,
                        filtered_gap_answers,
                    )
                    st.session_state.final_resume = final
                    st.session_state.final_resume_enhanced = "" # Reset enhanced resume
                    st.session_state.final_pdf_enhanced = None # Reset enhanced PDF
                    st.session_state.improvements_made = "" # Reset improvements log
                    
                    # Compile to PDF
                    pdf_bytes = compile_latex_to_pdf(final)
                    st.session_state.final_pdf = pdf_bytes
                    
                st.session_state.step = 4
                st.rerun()
            except Exception as e:
                st.error(
                    f"⚠️ OpenRouter Error: {str(e)}\n\n"
                    "This is often a temporary provider issue or a 504 Gateway Timeout. "
                    "Please go back to Step 1 (Setup) and try a different model."
                )


# ─────────────────────────────────────────────────────────────────────────────
# STEP 4 — Result
# ─────────────────────────────────────────────────────────────────────────────
elif st.session_state.step == 4:
    st.subheader("Your Tailored Resume")

    has_enhanced = bool(st.session_state.final_resume_enhanced)

    if has_enhanced:
        st.success("🎉 Resume enhanced successfully based on your mock interview details!")
        with st.expander("🔍 View improvements made:", expanded=True):
            st.markdown(st.session_state.improvements_made)
            
        tab1, tab2 = st.tabs(["✨ Enhanced Resume (Post-Interview)", "📄 Original Tailored Resume"])
        with tab1:
            col_dl1, col_dl2 = st.columns(2)
            with col_dl1:
                st.download_button(
                    label="⬇ Download LaTeX Code (.tex)",
                    data=st.session_state.final_resume_enhanced,
                    file_name="enhanced_tailored_resume.tex",
                    mime="text/plain",
                    key="download_enhanced_tex"
                )
            with col_dl2:
                if st.session_state.final_pdf_enhanced is not None:
                    st.download_button(
                        label="⬇ Download PDF (.pdf)",
                        data=st.session_state.final_pdf_enhanced,
                        file_name="enhanced_tailored_resume.pdf",
                        mime="application/pdf",
                        key="download_enhanced_pdf"
                    )
            
            st.markdown("")
            if st.session_state.final_pdf_enhanced is not None:
                render_pdf(st.session_state.final_pdf_enhanced)
            else:
                st.warning("⚠️ PDF compilation failed or was skipped. You can copy the LaTeX code below to Overleaf:")
                st.code(st.session_state.final_resume_enhanced, language="latex")
                
        with tab2:
            col_dl1, col_dl2 = st.columns(2)
            with col_dl1:
                st.download_button(
                    label="⬇ Download LaTeX Code (.tex)",
                    data=st.session_state.final_resume,
                    file_name="tailored_resume.tex",
                    mime="text/plain",
                    key="download_original_tex"
                )
            with col_dl2:
                if st.session_state.final_pdf is not None:
                    st.download_button(
                        label="⬇ Download PDF (.pdf)",
                        data=st.session_state.final_pdf,
                        file_name="tailored_resume.pdf",
                        mime="application/pdf",
                        key="download_original_pdf"
                    )
            
            st.markdown("")
            if st.session_state.final_pdf is not None:
                render_pdf(st.session_state.final_pdf)
            else:
                st.warning("⚠️ PDF compilation failed or was skipped. You can copy the LaTeX code below to Overleaf:")
                st.code(st.session_state.final_resume, language="latex")
    else:
        col_dl1, col_dl2 = st.columns(2)
        with col_dl1:
            st.download_button(
                label="⬇ Download LaTeX Code (.tex)",
                data=st.session_state.final_resume,
                file_name="tailored_resume.tex",
                mime="text/plain",
                key="download_std_tex"
            )
        with col_dl2:
            if st.session_state.final_pdf is not None:
                st.download_button(
                    label="⬇ Download PDF (.pdf)",
                    data=st.session_state.final_pdf,
                    file_name="tailored_resume.pdf",
                    mime="application/pdf",
                    key="download_std_pdf"
                )
        
        st.markdown("")
        if st.session_state.final_pdf is not None:
            render_pdf(st.session_state.final_pdf)
        else:
            st.warning("⚠️ PDF compilation failed or was skipped. You can copy the LaTeX code below to Overleaf:")
            st.code(st.session_state.final_resume, language="latex")

    # Offer Mock Interview if not already done
    if not has_enhanced and not st.session_state.interview_complete:
        st.markdown("")
        with st.container():
            st.markdown("""
            <div style="background-color: #f0f7ff; border: 1px solid #cce5ff; border-radius: 12px; padding: 1.5rem; margin-top: 1.5rem; margin-bottom: 1.5rem;">
                <h4 style="margin:0 0 0.5rem 0; color: #004085;">🎓 Ready to Practice? (Optional)</h4>
                <p style="margin:0 0 1rem 0; font-size:0.9rem; color: #004085;">
                    Would you like to have a mock interview with an AI hiring manager to practice? 
                    We will also analyze your answers to uncover achievements or skills you forgot to include, and automatically improve your resume!
                </p>
            </div>
            """, unsafe_allow_html=True)
            if st.button("Start Mock Interview 🚀", type="primary", key="start_interview_btn"):
                st.session_state.step = 5
                st.session_state.interview_started = True
                st.session_state.interview_messages = []
                st.session_state.interview_question_count = 0
                st.session_state.interview_complete = False
                st.rerun()

    st.divider()
    col_back, col_restart = st.columns([1, 5])
    with col_back:
        if st.button("← Edit Gaps"):
            st.session_state.step = 3
            st.rerun()
    with col_restart:
        if st.button("🔄 Start Over"):
            for k, v in DEFAULTS.items():
                st.session_state[k] = v
            st.rerun()


# ─────────────────────────────────────────────────────────────────────────────
# STEP 5 — Mock Interview
# ─────────────────────────────────────────────────────────────────────────────
elif st.session_state.step == 5:
    st.subheader("Mock Interview Practice & Resume Review")
    st.info(
        "💬 The AI hiring manager will ask you 3 questions based on the job requirements. "
        "Your answers will be analyzed to automatically find achievements or experience you forgot to write down, "
        "and seamlessly integrate them to make your resume stronger."
    )

    # Render previous messages
    for msg in st.session_state.interview_messages:
        with st.chat_message(msg["role"]):
            st.write(msg["content"])

    # If new interview, generate first question
    if len(st.session_state.interview_messages) == 0:
        try:
            with st.spinner("Hiring Manager is preparing the first question..."):
                llm = get_llm(st.session_state.api_key, st.session_state.model_name)
                first_question = get_interviewer_response(
                    llm,
                    st.session_state.job_ad,
                    st.session_state.final_resume,
                    []
                )
                st.session_state.interview_messages.append({"role": "assistant", "content": first_question})
                st.rerun()
        except Exception as e:
            st.error(
                f"⚠️ OpenRouter Error: {str(e)}\n\n"
                "This is often a temporary provider issue or a 504 Gateway Timeout. "
                "Please go back to Step 1 (Setup) and try a different model."
            )

    # User input
    if not st.session_state.interview_complete:
        if user_input := st.chat_input("Type your response here..."):
            # Append user response
            st.session_state.interview_messages.append({"role": "user", "content": user_input})
            st.session_state.interview_question_count += 1
            
            # Fetch next response or complete
            if st.session_state.interview_question_count < 3:
                try:
                    with st.spinner("Hiring Manager is thinking..."):
                        llm = get_llm(st.session_state.api_key, st.session_state.model_name)
                        next_q = get_interviewer_response(
                            llm,
                            st.session_state.job_ad,
                            st.session_state.final_resume,
                            st.session_state.interview_messages
                        )
                        st.session_state.interview_messages.append({"role": "assistant", "content": next_q})
                except Exception as e:
                    st.error(
                        f"⚠️ OpenRouter Error: {str(e)}\n\n"
                        "This is often a temporary provider issue or a 504 Gateway Timeout. "
                        "Please go back to Step 1 (Setup) and try a different model."
                    )
            else:
                st.session_state.interview_messages.append({
                    "role": "assistant", 
                    "content": "Thank you! We have completed the mock interview. Click the 'Enhance Resume' button below to merge any new achievements or details we discussed into your resume!"
                })
                st.session_state.interview_complete = True
            
            st.rerun()

    st.divider()
    col_back, col_action = st.columns([1, 5])
    with col_back:
        if st.button("← Back to Resume", key="back_to_resume"):
            st.session_state.step = 4
            st.rerun()
    with col_action:
        if st.session_state.interview_complete:
            if st.button("✨ Enhance Resume with Interview Answers →", type="primary", key="enhance_resume_btn"):
                try:
                    with st.spinner("Analyzing interview and refining resume..."):
                        llm = get_llm(st.session_state.api_key, st.session_state.model_name)
                        enhanced_resume, improvements = enhance_resume_with_interview(
                            llm,
                            st.session_state.job_ad,
                            st.session_state.final_resume,
                            st.session_state.interview_messages
                        )
                        st.session_state.final_resume_enhanced = enhanced_resume
                        st.session_state.improvements_made = improvements
                        
                        # Compile enhanced LaTeX to PDF
                        pdf_bytes = compile_latex_to_pdf(enhanced_resume)
                        st.session_state.final_pdf_enhanced = pdf_bytes
                        
                        st.session_state.step = 4
                        st.rerun()
                except Exception as e:
                    st.error(
                        f"⚠️ OpenRouter Error: {str(e)}\n\n"
                        "This is often a temporary provider issue or a 504 Gateway Timeout. "
                        "Please go back to Step 1 (Setup) and try a different model."
                    )
        else:
            if st.button("🏁 End Interview Early & Analyze", key="end_interview_early"):
                st.session_state.interview_complete = True
                st.rerun()