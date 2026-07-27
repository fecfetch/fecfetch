from ollama import embed
import numpy as np


festival_talks = [
    "🌿 The Next Nature: Designing with the Future in Mind — Explore how biomimicry, regenerative design, and synthetic biology are reshaping architecture, materials, and cities. Where does design end and nature begin?",
    "🧠 Neural Frontiers: The Brain-Computer Interface Revolution — From thought-controlled devices to memory enhancement, dive into the fast-evolving world of brain tech — and the ethical mazes it brings.",
    "🎨🤖 AI & the Soul of Art: Who Really Owns Creativity? — Artists, coders, and philosophers debate the rise of generative art. Can machines make meaning? And where does human intuition still reign supreme?",
    "💼🚫 Post-Work: Imagining a Life Beyond Jobs — As automation reshapes labor, what comes next? UBI, digital nomadism, reputation economies — a candid discussion about freedom, purpose, and survival.",
    "🪐 Planet B: Terraforming Ideas for Earth 2.0 — Science fiction meets climate urgency. This talk blends real research with wild speculation — from Mars domes to floating cities in the clouds of Venus.",
    "🕶️🌐 Reality is Optional: The Rise of Immersive Worlds — VR, AR, XR — and whatever’s next. What happens when our digital spaces feel more real than reality itself? And who gets to write the rules?",
    "🧬⏳ The Ethics of Immortality: Living Forever in a Mortal World — Cryonics, gene editing, mind uploading — tech is chasing eternal life. But what would it mean for love, loss, and the human condition?",
    "💻⚖️ Code as Culture: Programming the Future We Want — Code is not neutral — it shapes societies. This talk explores how developers are becoming the new lawmakers, and how we hold them accountable.",
    "🕸️🛠️ The Wild Web: Reclaiming the Internet from Algorithms — Can we rebuild the web for people, not profit? Meet the rebels, hackers, and dreamers creating decentralized, community-first digital spaces.",
    "🕰️🚀 Time Travelers Welcome: Building the Long Now — Futurists, historians, and deep-time thinkers gather to explore projects that think in centuries — from 10,000-year clocks to interstellar archives."
]
document_inputs = [f"search_document: {talk}" for talk in festival_talks]
response = embed(model='nomic-embed-text', input=document_inputs)

embedding = response['embeddings']

print(len(embedding), len(embedding[0]), len(embedding[0]))



vectors = np.array(embedding)

query = np.array(embed(model='nomic-embed-text', input='search_query: I am interested in artificial intelligence, machine learning, and generative AI')['embeddings'])

# Compute Euclidean distances
differences = vectors - query  # shape: (n_vectors, vector_dim)
distances = np.linalg.norm(differences, axis=1)

# Index of closest vector
closest_index = np.argmin(distances)

# Sorted indices by distance
sorted_indices = np.argsort(distances)

print("Closest vector index:", closest_index)
print("Distance:", distances[closest_index])
print("Sorted indices by distance:", sorted_indices)
sorted_festival_talks = [festival_talks[i] for i in sorted_indices]

# Optionally print it
for num, talk in enumerate(sorted_festival_talks):
    print(num+1, talk)
    print()