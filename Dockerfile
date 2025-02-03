# Use an official Python image as a base
FROM python:3.10

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Ollama
RUN curl -fsSL https://ollama.ai/install.sh | sh

# Start Ollama in the background, pull models, then stop it
RUN ollama serve & sleep 5 && ollama pull deepseek-r1:7b && ollama pull deepseek-coder-v2 && pkill ollama

# Pull models directly into the container
#RUN ollama pull deepseek-r1:7b
#RUN ollama pull deepseek-coder-v2

# Copy the app code
COPY . .

# Expose the Streamlit default port
EXPOSE 8501

# Start Ollama and the Streamlit app
CMD ["sh", "-c", "ollama serve & streamlit run llm_app.py --server.port 8501 --server.address 0.0.0.0"]
