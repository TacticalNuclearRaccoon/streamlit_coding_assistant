# Use an official Python image as a base
FROM python:3.10

# Set working directory
WORKDIR /app

# System deps (curl for Ollama install, zstd for Ollama extraction)
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates zstd \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Copy the app code
COPY . .

# Entrypoint script (pull model at container startup)
RUN chmod +x /app/entrypoint.sh

# Expose the Streamlit default port
EXPOSE 8501

# Start Ollama, pull a model if needed, then run the Streamlit app
CMD ["/app/entrypoint.sh"]
