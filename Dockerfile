# Start from a lightweight Python base image
FROM python:3.12-slim

# Set the working directory inside the container
WORKDIR /app

# Copy dependency list first (for caching efficiency)
COPY requirements.txt .

# Install dependencies inside the container
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app code
COPY app.py .

# Tell Docker this container listens on port 5000
EXPOSE 5000

# Command to run when the container starts
CMD ["python", "app.py"]
