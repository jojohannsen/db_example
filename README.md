# Database Example - AI-Powered SQL Query System

A demonstration project that shows how to use AI (Claude) to generate and execute SQL queries against a product inspection database using LangChain.

## Overview

This project creates a SQLite database with sample data for a product inspection system and provides an AI-powered interface to query the data using natural language questions. The AI converts your questions into SQL queries and returns formatted answers.

## Database Schema

The system includes four main tables:

- **suppliers** - Vendor information (20 records)
- **products** - Items being inspected (50 records across multiple categories)
- **inspectors** - Quality control personnel (15 records with different certification levels)
- **inspections** - Inspection records with pass/fail status and scores (300+ records)

### Sample Data Categories
- **Products**: Widgets, Gadgets, Components, Tools, Sensors, Motors, Bearings, Switches, Cables, Housings
- **Inspector Levels**: Junior, Senior, Lead
- **Inspection Status**: Pass, Fail, Conditional, Pending

## Files

- `fake_tables.sql` - Database schema definition
- `fake_data.sql` - Sample data insertion
- `query_data.py` - AI-powered query engine
- `runit.sh` - Demo script that sets up database and runs example queries (Unix/Linux/macOS)
- `setup_and_run.sh` - Automated setup script with conda environment (Unix/Linux/macOS)
- `setup_and_run.bat` - Automated setup script using system Python (Windows)
- `requirements.txt` - Python dependencies

## Setup Instructions

### Quick Start (Automated Setup)

**For Unix/Linux/macOS:**
```bash
./setup_and_run.sh
```

**For Windows:**
```cmd
setup_and_run.bat
```

These scripts will automatically:
1. Set up the Python environment (conda on Unix/Linux/macOS, system Python on Windows)
2. Install dependencies
3. Create the database and run example queries

### Manual Setup

#### 1. Install Dependencies

**Unix/Linux/macOS:**
```bash
pip install -r requirements.txt
```

**Windows:**
```cmd
pip install -r requirements.txt
```

#### 2. Set Environment Variables

You'll need an Anthropic API key to use Claude:

**Unix/Linux/macOS:**
```bash
export ANTHROPIC_API_KEY="your-api-key-here"
```

**Windows:**
```cmd
set ANTHROPIC_API_KEY=your-api-key-here
```

#### 3. Run the Example

**Unix/Linux/macOS:**
```bash
bash runit.sh
```

**Windows (with Git Bash):**
```bash
bash runit.sh
```

**Windows (without Git Bash):**
The batch script will automatically handle database creation and run queries directly.

This will:
1. Create the SQLite database (`fake.db`) if it doesn't exist
2. Run two example queries:
   - "Who did the most inspections?"
   - "What sort of things do we inspect?"

### 4. Custom Queries

You can ask your own questions:

**Unix/Linux/macOS:**
```bash
python query_data.py "How many products failed inspection?"
python query_data.py "Which inspector has the highest average scores?"
python query_data.py "Show me all products from Acme Manufacturing"
```

**Windows:**
```cmd
python query_data.py "How many products failed inspection?"
python query_data.py "Which inspector has the highest average scores?"
python query_data.py "Show me all products from Acme Manufacturing"
```

## How It Works

1. **Natural Language Input**: You ask a question in plain English
2. **AI SQL Generation**: Claude analyzes the question and database schema to generate appropriate SQL
3. **Query Execution**: The SQL is executed against the SQLite database
4. **AI Response**: Claude formats the results into a natural language answer

## Example Queries

Try asking questions like:
- "Which products have the lowest inspection scores?"
- "How many inspections were done in September 2024?"
- "Which supplier has the most expensive products?"
- "Show me all failed inspections and their reasons"
- "Which inspector certified the most products?"
- "What's the average inspection score by product category?"

## Technical Details

- **AI Model**: Claude Sonnet 4 (claude-sonnet-4-20250514)
- **Framework**: LangChain with structured output
- **Database**: SQLite with in-memory processing for schema, file storage for data
- **Query Tool**: LangChain's QuerySQLDatabaseTool
- **Validation**: Pydantic models for structured SQL generation

## Requirements

- Python 3.8+
- Anthropic API key
- Internet connection for AI model access

## License

This is a demonstration project for educational purposes.