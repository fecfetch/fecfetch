import sys
from google import genai

# Check if the user actually passed the API key argument
if len(sys.argv) < 2:
    print("Error: Missing API key.")
    print("Usage: python3 first.py [YOUR_API_KEY]")
    sys.exit(1) 

gemini_api_key = sys.argv[1]

client = genai.Client(api_key=gemini_api_key)

# Generate the response
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Write a one-sentence bedtime story about a unicorn."
)

print(response.text)