#!/bin/bash

# Script to pull latest changes from GitHub

echo "Pulling latest changes from GitHub..."
echo "======================================"
echo ""

cd "$(dirname "$0")/.."

# Fetch latest changes
echo "Fetching from origin..."
GIT_SSL_NO_VERIFY=1 git fetch origin

# Check status
echo ""
echo "Current status:"
git status

# Pull changes
echo ""
echo "Pulling changes..."
GIT_SSL_NO_VERIFY=1 git pull origin main

echo ""
echo "Done! Refresh Xcode to see the changes."
