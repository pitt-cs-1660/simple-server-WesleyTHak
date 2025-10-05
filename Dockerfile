############################
# BUILD STAGE
############################
FROM python:3.12 AS builder

# Create venv and install dependencies
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Upgrade pip
RUN pip install --upgrade pip

# Copy dependency file
COPY pyproject.toml ./

# Install dependencies needed for app + testing
RUN pip install fastapi uvicorn pytest httpx

# Copy application code and tests into build image
COPY cc_simple_server ./cc_simple_server
COPY tests ./tests

############################
# FINAL STAGE
############################
FROM python:3.12-slim

WORKDIR /app
ENV PYTHONPATH=/app

# Copy virtual environment
COPY --from=builder /opt/venv /opt/venv

# Copy application and tests
COPY cc_simple_server ./cc_simple_server
COPY tests ./tests

# Create non-root user and give ownership
RUN useradd -m appuser
RUN chown -R appuser:appuser /app
USER appuser

# Add venv to PATH
ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 8000

# Run FastAPI app
CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]
