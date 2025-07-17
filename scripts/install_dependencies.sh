#!/bin/bash

# Update package lists (already in your log, good to keep)
echo "Updating package lists..."
apt update

# Install python3 and python3-pip if they aren't already (your logs show they are)
echo "Ensuring python3 and python3-pip are installed..."
apt install -y python3 python3-pip python3-venv # python3-venv is crucial for creating venvs

# --- NEW: Create and activate a virtual environment ---
VENV_DIR="/opt/venv/your_app_name" # Choose a suitable location for your virtual environment

echo "Creating virtual environment at $VENV_DIR..."
# Create the virtual environment
python3 -m venv "$VENV_DIR"

echo "Activating virtual environment..."
# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# --- Install your application's Python dependencies using pip ---
# Assuming your Python dependencies are listed in a requirements.txt file
echo "Installing Python dependencies from requirements.txt..."
# Use the pip within the virtual environment
pip install -r /opt/codedeploy-agent/deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive/requirements.txt # Adjust path to your requirements.txt

# You can add other shell commands here if needed, they will run within the activated venv
# For example, if you need to install specific system packages beyond Python for your app:
# apt install -y some-other-system-package

# IMPORTANT: The virtual environment remains active only for this script's execution.
# When your application starts, you'll need to activate it again or use the full path
# to its Python executable (e.g., /opt/venv/your_app_name/bin/python)

echo "Dependency installation complete."
