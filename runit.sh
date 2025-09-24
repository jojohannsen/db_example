#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Setting up database ==="
echo "Script location: $SCRIPT_DIR"
echo "Working directory: $(pwd)"

# -- create database tables and fake data (only if db doesn't exist)
if [ ! -f fake.db ]; then
    echo "Creating database..."
    cat "$SCRIPT_DIR/fake_tables.sql" | sqlite3 fake.db
    cat "$SCRIPT_DIR/fake_data.sql" | sqlite3 fake.db
    echo "Database created: $(pwd)/fake.db"
else
    echo "Database already exists: $(pwd)/fake.db"
fi

echo ""
echo "=== Running example queries ==="

# query the data
echo ""
echo "Question: Who did the most inspections?"
python "$SCRIPT_DIR/query_data.py" "Who did the most inspections?"

echo ""
echo "Question: What sort of things do we inspect?"
python "$SCRIPT_DIR/query_data.py" "What sort of things do we inspect?"
