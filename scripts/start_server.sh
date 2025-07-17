#!/bin/bash
# Start the Flask application using Gunicorn (recommended for production)
# First, ensure Gunicorn is installed
pip3 install gunicorn

# Stop any running instances of the app
pkill gunicorn || true

# Start Gunicorn in the background, listening on port 80
nohup gunicorn --bind 0.0.0.0:80 app:app > /var/log/python-app.log 2>&1 &
