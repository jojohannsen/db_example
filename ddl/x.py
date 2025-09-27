#!/usr/bin/env python3
"""
Command line tool for converting natural language to SQL using LangChain.
"""

import argparse
import sys
from typing import Optional
from langchain.chat_models import init_chat_model
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.messages import HumanMessage, SystemMessage


def make_query(ddl: str, what_query_does: str) -> str:
    """
    Generate SQL query from DDL and natural language description.
    
    Args:
        ddl: Database schema definition (CREATE TABLE statements)
        what_query_does: Natural language description of desired query
        
    Returns:
        Generated SQL query as string
    """
    # Initialize the chat model
    llm = init_chat_model("anthropic:claude-sonnet-4-20250514")
    
    # Create a prompt template for text-to-SQL conversion
    prompt_template = ChatPromptTemplate.from_messages([
        ("system", """You are an expert SQL developer. Given a database schema (DDL) and a natural language question, generate a SQL query that answers the question.

Rules:
1. Only use tables and columns that exist in the provided schema
2. Generate syntactically correct SQL
3. Return ONLY the SQL query, no explanations or markdown
4. Use appropriate JOINs when querying multiple tables
5. Include proper WHERE clauses, ORDER BY, GROUP BY as needed
6. Use standard SQL syntax that works across most databases

Database Schema:
{ddl}"""),
        ("human", "Generate a SQL query that: {question}")
    ])
    
    # Create the chain
    chain = prompt_template | llm
    
    # Generate the query
    try:
        response = chain.invoke({
            "ddl": ddl,
            "question": what_query_does
        })
        
        # Extract the SQL from the response
        sql_query = response.content.strip()
        
        # Clean up any potential markdown formatting
        if sql_query.startswith("```sql"):
            sql_query = sql_query[6:]
        if sql_query.startswith("```"):
            sql_query = sql_query[3:]
        if sql_query.endswith("```"):
            sql_query = sql_query[:-3]
            
        return sql_query.strip()
        
    except Exception as e:
        raise Exception(f"Error generating SQL query: {str(e)}")


def read_file(filepath: str) -> str:
    """Read content from a file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        raise FileNotFoundError(f"File not found: {filepath}")
    except Exception as e:
        raise Exception(f"Error reading file {filepath}: {str(e)}")


def main():
    parser = argparse.ArgumentParser(
        description="Generate SQL queries from natural language descriptions",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python text_to_sql.py -d schema.sql -q "Find all users who registered last month"
  python text_to_sql.py -d "CREATE TABLE users (id INT, name VARCHAR(100), email VARCHAR(100));" -q "Get all user emails"
  python text_to_sql.py --ddl-file schema.sql --question "Count orders by status"
        """
    )
    
    # DDL input options (mutually exclusive)
    ddl_group = parser.add_mutually_exclusive_group(required=True)
    ddl_group.add_argument(
        "-d", "--ddl",
        type=str,
        help="DDL string containing table definitions"
    )
    ddl_group.add_argument(
        "--ddl-file",
        type=str,
        help="Path to file containing DDL statements"
    )
    
    # Question input
    parser.add_argument(
        "-q", "--question",
        type=str,
        required=True,
        help="Natural language description of what the query should do"
    )
    
    # Output options
    parser.add_argument(
        "-o", "--output",
        type=str,
        help="Output file path (if not specified, prints to stdout)"
    )
    
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Show detailed output including schema summary"
    )
    
    args = parser.parse_args()
    
    try:
        # Get DDL content
        if args.ddl:
            ddl_content = args.ddl
        else:
            ddl_content = read_file(args.ddl_file)
        
        if args.verbose:
            print("Schema loaded successfully", file=sys.stderr)
            print(f"Question: {args.question}", file=sys.stderr)
            print("Generating SQL query...", file=sys.stderr)
        
        # Generate SQL query
        sql_query = make_query(ddl_content, args.question)
        
        # Output the result
        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(sql_query)
            if args.verbose:
                print(f"SQL query written to: {args.output}", file=sys.stderr)
        else:
            print(sql_query)
            
    except KeyboardInterrupt:
        print("\nOperation cancelled by user", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
