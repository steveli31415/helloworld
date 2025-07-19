# Use Python 3.11 slim image for smaller size
FROM python:3.11-slim

# Set working directory in container
WORKDIR /app

# Copy requirements first (for better Docker layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Create non-root user for security
RUN useradd --create-home --shell /bin/bash app && chown -R app:app /app
USER app

# Expose port 5000
EXPOSE 5000

# Use gunicorn for production deployment
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"] 