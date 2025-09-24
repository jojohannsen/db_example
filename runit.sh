# -- create database tables and fake data (only if db doesn't exist)
if [ ! -f fake.db ]; then
    cat fake_tables.sql | sqlite3 fake.db
    cat fake_data.sql | sqlite3 fake.db
fi

# query the data
echo "Who did the most inspections?"
python query_data.py "Who did the most inspections?"
echo "What sort of things do we inspect?"
python query_data.py "What sort of things do we inspect?"
