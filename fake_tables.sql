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

