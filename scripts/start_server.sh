#!/bin/bash

# Define the virtual environment directory (MUST match install_dependencies.sh)
VENV_DIR="/opt/venv/your_app_name" # Make sure this matches

# Define the application directory (where your app.py is located in the deployment bundle)
# Adjust this path based on where CodeDeploy extracts your files.
# Common paths are /opt/codedeploy-agent/deployment-root/<DG_ID>/<DEP_ID>/deployment-archive/
APP_DIR="/opt/codedeploy-agent/deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive"

# --- Recommended: Stop any existing Gunicorn process cleanly ---
echo "Attempting to stop existing Gunicorn processes..."
# This command will stop Gunicorn processes that are bound to the correct port/app.
# Replace 'app:app' with the actual entry point if different.
# Also, ensure you stop only processes related to *this* app, not other gunicorn apps if any.
# A more robust way would be to check if the process is managed by systemd, and stop that.
# For now, pkill is fine, but be careful in environments with multiple Gunicorn apps.
pkill -f "gunicorn.*app:app" || true # More specific kill


# --- Activate virtual environment ---
echo "Activating virtual environment: $VENV_DIR"
source "$VENV_DIR/bin/activate"

# --- Start Gunicorn ---
echo "Starting Gunicorn on port 80..."
# Navigate to the app's directory first so 'app:app' resolves correctly
cd "$APP_DIR"

# Start Gunicorn in the background.
# Using 'exec' ensures Gunicorn replaces the current shell, making it
# slightly cleaner if this script is the last thing run by CodeDeploy.
# Otherwise, nohup is fine.
# For better logging and process management, consider systemd (see below).
nohup gunicorn --bind 0.0.0.0:80 app:app > /var/log/python-app.log 2>&1 &

# Optional: Add a small delay and check if Gunicorn started
sleep 5
sudo netstat -tulnp | grep 80 # Changed to 80 as per your script

echo "Gunicorn startup script finished."
