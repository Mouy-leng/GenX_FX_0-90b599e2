import sqlite3


def setup_database():
    """
    Sets up the SQLite database by creating tables and seeding initial data.
    This function is idempotent and can be run multiple times safely.
    """
    conn = sqlite3.connect("genxdb_fx.db")
    cursor = conn.cursor()

    # Create users table
    cursor.execute(
        """
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        is_active INTEGER DEFAULT 1
    )
    """
    )

    # Create trading_pairs table
    cursor.execute(
        """
    CREATE TABLE IF NOT EXISTS trading_pairs (
        id INTEGER PRIMARY KEY,
        symbol TEXT NOT NULL UNIQUE,
        base_currency TEXT NOT NULL,
        quote_currency TEXT NOT NULL,
        is_active INTEGER DEFAULT 1
    )
    """
    )

    # Seed initial data (if tables are empty)
    cursor.execute("SELECT COUNT(*) FROM users")
    if cursor.fetchone()[0] == 0:
        cursor.execute(
            "INSERT INTO users (username, email) VALUES (?, ?)",
            ("testuser", "test@example.com"),
        )

    cursor.execute("SELECT COUNT(*) FROM trading_pairs")
    if cursor.fetchone()[0] == 0:
        cursor.execute(
            "INSERT INTO trading_pairs (symbol, base_currency, quote_currency) VALUES (?, ?, ?)",
            ("EURUSD", "EUR", "USD"),
        )
        cursor.execute(
            "INSERT INTO trading_pairs (symbol, base_currency, quote_currency) VALUES (?, ?, ?)",
            ("GBPUSD", "GBP", "USD"),
        )

    conn.commit()
    conn.close()
    print("Database setup complete.")


if __name__ == "__main__":
    setup_database()
