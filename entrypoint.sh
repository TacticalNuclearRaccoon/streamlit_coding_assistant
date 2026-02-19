#!/bin/sh
set -eu

MODEL="${OLLAMA_MODEL:-qwen2.5-coder:3b}"
PORT="${PORT:-8501}"

echo "Starting Ollama..."
ollama serve >/tmp/ollama.log 2>&1 &
OLLAMA_PID="$!"

cleanup() {
  # Best-effort shutdown
  if kill -0 "$OLLAMA_PID" >/dev/null 2>&1; then
    kill "$OLLAMA_PID" >/dev/null 2>&1 || true
  fi
}

trap cleanup INT TERM EXIT

echo "Waiting for Ollama to be ready..."
i=0
while ! ollama list >/dev/null 2>&1; do
  i=$((i + 1))
  if [ "$i" -ge 30 ]; then
    echo "Ollama did not become ready in time. Last log lines:"
    tail -n 50 /tmp/ollama.log || true
    exit 1
  fi
  sleep 1
done

if ! ollama show "$MODEL" >/dev/null 2>&1; then
  echo "Pulling model: $MODEL"
  ollama pull "$MODEL"
else
  echo "Model already present: $MODEL"
fi

echo "Starting Streamlit on port $PORT..."
streamlit run llm_app.py --server.port "$PORT" --server.address 0.0.0.0

