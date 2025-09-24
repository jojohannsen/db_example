#!/bin/bash

# Setup and run script for db_example project
# Can be executed from any directory

set -e  # Exit on any error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
ENV_NAME="db_example_env"
CURRENT_DIR=$(pwd)

echo "=== DB Example Setup and Run Script ==="
echo "Current directory: $CURRENT_DIR"
echo "Project directory: $PROJECT_DIR"

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Project directory $PROJECT_DIR does not exist!"
    echo "Please run this script from the db_example project directory"
    exit 1
fi

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo "Error: conda is not available in PATH"
    echo "Please ensure conda is installed and initialized"
    exit 1
fi

echo ""
echo "=== Step 1: Creating conda environment '$ENV_NAME' ==="

# Remove existing environment if it exists
if conda env list | grep -q "^$ENV_NAME "; then
    echo "Environment '$ENV_NAME' already exists. Removing it..."
    conda env remove -n "$ENV_NAME" -y
fi

# Create new environment with Python 3.12
echo "Creating new conda environment with Python 3.12..."
conda create -n "$ENV_NAME" python=3.12 -y

echo ""
echo "=== Step 2: Installing requirements ==="

# Activate environment and install requirements
echo "Activating environment and installing requirements..."
eval "$(conda shell.bash hook)"
conda activate "$ENV_NAME"

# Install requirements from the project directory
pip install -r "$PROJECT_DIR/requirements.txt"

echo ""
echo "=== Step 3: Setting up working directory ==="

# Create a working directory in current location
WORK_DIR="$CURRENT_DIR/db_example_work"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "Working directory: $WORK_DIR"

echo ""
echo "=== Step 4: Running the example ==="

# Check for ANTHROPIC_API_KEY
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "Warning: ANTHROPIC_API_KEY environment variable is not set"
    echo "Please set it with: export ANTHROPIC_API_KEY='your-api-key-here'"
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting. Please set ANTHROPIC_API_KEY and run again."
        exit 1
    fi
fi

# Run the project script from the project directory but in our working directory
echo "Executing runit.sh..."
cd "$WORK_DIR"
bash "$PROJECT_DIR/runit.sh"

echo ""
echo "=== Execution Complete ==="
echo "Environment: $ENV_NAME (still activated)"
echo "Working directory: $WORK_DIR"
echo "Database created at: $WORK_DIR/fake.db"
echo ""
echo "To run custom queries, use:"
echo "  python $PROJECT_DIR/query_data.py \"Your question here\""
echo ""
echo "To deactivate environment: conda deactivate"
echo "To remove environment: conda env remove -n $ENV_NAME"