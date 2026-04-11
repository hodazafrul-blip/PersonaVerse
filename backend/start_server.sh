#!/bin/bash

# Ensure working directory is the backend folder
cd "$(dirname "$0")"

# Start the uvicorn server on 0.0.0.0 so external devices (like your phone) can connect
# Port 8000
echo "Starting PersonaVerse Backend Intelligence..."
echo "Your Phone must be on the same Wi-Fi. Accessing via: http://192.168.1.23:8000"

python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
