import sys
import sqlite3
from langchain.chains.sql_database.prompt import SQL_PROMPTS
from sqlalchemy import create_engine, StaticPool
from pydantic import BaseModel, Field
from langchain_community.tools import QuerySQLDatabaseTool
from langchain_community.utilities import SQLDatabase
from langchain.chains import create_sql_query_chain
from langchain.chat_models import init_chat_model

class SqlQuery(BaseModel):
    sql: str = Field(description="SQL query based on user request and table information")
    explanation: str = Field(description="Explanation of query", default="None")

# Custom parser to extract SQL from Sonnet's structured response
def parse_sql_query(output: SqlQuery) -> str:
    return output.sql

def generate_answer(question: str, sql_query: str, sql_result) -> str:
    prompt = f"""
Given the following user question, corresponding SQL query, and SQL result, answer the user question.

Question: {question}
SQL Query: {sql_query}
SQL Result: {sql_result}

Answer:
"""
    llm = init_chat_model("anthropic:claude-sonnet-4-20250514")
    response = llm.invoke(prompt)
    return response.content.strip()

def query_database(question: str):
    # Database schema for the query chain
    table_info = """

    -- Inspection Database Schema
    -- SQLite database for tracking product inspections

    -- Create Tables
    CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact_email TEXT,
        phone TEXT,
        address TEXT,
        created_date DATE DEFAULT CURRENT_DATE
    );

    CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        supplier_id INTEGER NOT NULL,
        price DECIMAL(10,2),
        category TEXT,
        created_date DATE DEFAULT CURRENT_DATE,
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
    );

    CREATE TABLE inspectors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        certification_level TEXT CHECK(certification_level IN ('Junior', 'Senior', 'Lead')),
        hire_date DATE,
        active BOOLEAN DEFAULT 1
    );

    CREATE TABLE inspections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        inspector_id INTEGER NOT NULL,
        inspection_date DATE NOT NULL,
        status TEXT CHECK(status IN ('Pass', 'Fail', 'Conditional', 'Pending')),
        score INTEGER CHECK(score BETWEEN 0 AND 100),
        notes TEXT,
        created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (inspector_id) REFERENCES inspectors(id)
    );
    """

    # Create an in-memory SQLite database and execute schema
    connection = sqlite3.connect(":memory:", check_same_thread=False)
    connection.executescript(table_info)

    # Create SQLAlchemy engine using the in-memory connection
    engine = create_engine(
        "sqlite://",
        creator=lambda: connection,
        poolclass=StaticPool,
        connect_args={"check_same_thread": False},
    )

    # Create the SQLDatabase object from the engine
    memory_db = SQLDatabase(engine)

    # Initialize the language model with structured output
    llm = init_chat_model("anthropic:claude-sonnet-4-20250514", temperature=0)
    structured_llm = llm.with_structured_output(SqlQuery)

    # Set up the query chain
    prompt = SQL_PROMPTS['sqlite']
    prompt = prompt.partial(table_info=table_info, top_k=5)

    # Create the structured query chain directly
    write_query = prompt | structured_llm | parse_sql_query
    # to see just the sql
    query = write_query.invoke({"input": question})
    print(f"   sql: {query}")

    # Execute SQL query on the actual database
    db = SQLDatabase.from_uri("sqlite:///fake.db")
    execute_query = QuerySQLDatabaseTool(db=db)

    # Create combined chain
    combined_chain = write_query | execute_query

    # Run the chain
    result = combined_chain.invoke({"input": question})
    return query, result

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python query_data.py \"<your question>\"")
        sys.exit(1)

    question = sys.argv[1]
    query, query_result = query_database(question)
    result = generate_answer(question, query, query_result)
    print(result)
