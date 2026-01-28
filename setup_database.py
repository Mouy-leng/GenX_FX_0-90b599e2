#!/usr/bin/env python3
"""
Database Setup Script for GenX-FX Trading Platform
This script initializes the SQLite database with the required tables and schema.
"""

import os
import sys
import logging
import sqlite3
from pathlib import Path

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def create_database_schema():
    """
    Creates the database schema for the trading platform, including all necessary
    tables and initial data.
    """

    db_path = "genxdb_fx.db"
    logger.info(f"Creating database: {db_path}")

    try:
        # Create database connection
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        # Create tables
        create_tables(cursor)

        # Insert initial data
        insert_initial_data(cursor)

        # Commit changes
        conn.commit()
        conn.close()

        logger.info("✅ Database schema setup complete!")

    except Exception as e:
        logger.error(f"❌ Database error: {e}")
        sys.exit(1)


def create_tables(cursor):
    """
    Creates all the required tables in the database.

    Args:
        cursor: The database cursor object.
    """

    # SQL statements to create tables
    tables_sql = [
        """
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            is_active BOOLEAN DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS trading_accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            account_name TEXT NOT NULL,
            broker TEXT NOT NULL,
            account_number TEXT,
            balance REAL DEFAULT 0.00,
            currency TEXT DEFAULT 'USD',
            is_active BOOLEAN DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS trading_pairs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            symbol TEXT UNIQUE NOT NULL,
            base_currency TEXT NOT NULL,
            quote_currency TEXT NOT NULL,
            is_active BOOLEAN DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """,
        """
        -- Performance Optimization: Index for faster queries on active trading pairs
        CREATE INDEX IF NOT EXISTS idx_trading_pairs_is_active ON trading_pairs (is_active)
        """,
        """
        CREATE TABLE IF NOT EXISTS market_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            symbol TEXT NOT NULL,
            timestamp TIMESTAMP NOT NULL,
            open_price REAL,
            high_price REAL,
            low_price REAL,
            close_price REAL,
            volume REAL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS trading_signals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            symbol TEXT NOT NULL,
            signal_type TEXT NOT NULL,
            confidence REAL,
            price REAL,
            timestamp TIMESTAMP NOT NULL,
            model_version TEXT,
            features TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS trades (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            account_id INTEGER,
            symbol TEXT NOT NULL,
            trade_type TEXT NOT NULL,
            quantity REAL NOT NULL,
            price REAL NOT NULL,
            total_amount REAL NOT NULL,
            status TEXT DEFAULT 'PENDING',
            signal_id INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            executed_at TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (account_id) REFERENCES trading_accounts(id),
            FOREIGN KEY (signal_id) REFERENCES trading_signals(id)
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS model_predictions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            symbol TEXT NOT NULL,
            model_name TEXT NOT NULL,
            prediction_type TEXT NOT NULL,
            prediction_value REAL,
            confidence REAL,
            timestamp TIMESTAMP NOT NULL,
            features TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS system_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            level TEXT NOT NULL,
            message TEXT NOT NULL,
            module TEXT,
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """,
    ]

    for i, sql in enumerate(tables_sql, 1):
        try:
            cursor.execute(sql)
            logger.info(f"✅ Created table {i}/{len(tables_sql)}")
        except Exception as e:
            logger.warning(f"⚠️  Table creation warning (might already exist): {e}")

    # --- Performance Optimization: Add Indexes ---
    # To speed up queries on frequently filtered columns, we add indexes.
    # The 'is_active' column is used in API endpoints to filter active
    # users and trading pairs, so an index here will have a significant
    # performance impact.
    # --------------------------------------------------------------------------
    indexes_sql = [
        "CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active)",
        "CREATE INDEX IF NOT EXISTS idx_trading_pairs_is_active ON trading_pairs(is_active)",
    ]

    for i, sql in enumerate(indexes_sql, 1):
        try:
            cursor.execute(sql)
            logger.info(f"✅ Created index {i}/{len(indexes_sql)}")
        except Exception as e:
            logger.warning(f"⚠️  Index creation warning: {e}")


def insert_initial_data(cursor):
    """
    Inserts initial data into the database, such as a default user and
    a list of trading pairs.

    Args:
        cursor: The database cursor object.
    """

    initial_data_sql = [
        """
        INSERT OR IGNORE INTO users (username, email, password_hash) VALUES
        ('admin', 'admin@genxdbxfx1.com', 'hashed_password_placeholder')
        """,
        """
        INSERT OR IGNORE INTO trading_pairs (symbol, base_currency, quote_currency) VALUES
        ('EUR/USD', 'EUR', 'USD'),
        ('GBP/USD', 'GBP', 'USD'),
        ('USD/JPY', 'USD', 'JPY'),
        ('USD/CHF', 'USD', 'CHF'),
        ('AUD/USD', 'AUD', 'USD'),
        ('USD/CAD', 'USD', 'CAD'),
        ('NZD/USD', 'NZD', 'USD'),
        ('EUR/GBP', 'EUR', 'GBP'),
        ('EUR/JPY', 'EUR', 'JPY'),
        ('GBP/JPY', 'GBP', 'JPY')
        """,
    ]

    for i, sql in enumerate(initial_data_sql, 1):
        try:
            cursor.execute(sql)
            logger.info(f"✅ Inserted initial data {i}/{len(initial_data_sql)}")
        except Exception as e:
            logger.warning(f"⚠️  Data insertion warning: {e}")


if __name__ == "__main__":
    logger.info("🚀 Setting up GenX-FX Trading Platform Database...")
    create_database_schema()
    logger.info("✅ Database setup complete!")
