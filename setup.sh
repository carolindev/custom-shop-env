#!/usr/bin/env bash

set -e  # Exit script on any error

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Ensure required environment variables are set
if [ -z "$BACKEND_REPO_URL" ] || [ -z "$FRONTEND_REPO_URL" ] || [ -z "$BACKEND_DIR" ] || [ -z "$FRONTEND_DIR" ]; then
    echo "Error: Required environment variables (BACKEND_REPO_URL, FRONTEND_REPO_URL, BACKEND_DIR, FRONTEND_DIR) are not set in .env"
    exit 1
fi

echo "========== Initial Setup =========="

# Clone backend repo if not exists
if [ ! -d "$BACKEND_DIR" ]; then
    echo "Cloning backend repository into $BACKEND_DIR from $BACKEND_REPO_URL..."
    git clone "$BACKEND_REPO_URL" "$BACKEND_DIR"
else
    echo "Backend repository already exists. Pulling latest changes..."
    cd "$BACKEND_DIR"
    git pull origin main || git pull origin master
    cd ..
fi

# Clone frontend repo if not exists
if [ ! -d "$FRONTEND_DIR" ]; then
    echo "Cloning frontend repository into $FRONTEND_DIR from $FRONTEND_REPO_URL..."
    git clone "$FRONTEND_REPO_URL" "$FRONTEND_DIR"
else
    echo "Frontend repository already exists. Pulling latest changes..."
    cd "$FRONTEND_DIR"
    git pull origin main || git pull origin master
    cd ..
fi

echo "========== Building and Starting Docker Services =========="
docker compose up --build -d

echo "Docker containers are now running."

# Wait a few seconds to ensure the API is ready
echo "Waiting for API to be ready..."
sleep 30

echo "========== Starting Next.js App =========="
cd "$FRONTEND_DIR" || { echo "Error: frontend directory not found!"; exit 1; }

echo "Installing dependencies..."
npm install

echo "Starting Next.js in development mode..."
npm run dev