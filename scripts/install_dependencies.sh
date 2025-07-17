#!/bin/bash
# Install Python and pip if not already present
sudo apt update -y
sudo apt install -y python3 python3-pip

# Install application dependencies
pip3 install -r /var/www/python-hello-world/requirements.txt
