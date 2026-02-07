"""
Trading Bridge Service - Connects Docker services to MT5 Terminal
"""

import json
import logging
import os
import socket
import sys
from pathlib import Path

from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Setup logging
logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


def load_symbols_config():
    """
    Load symbols configuration using hybrid approach:
    1. Read SYMBOLS environment variable (comma-separated list)
    2. Load detailed config from symbols.json
    3. Merge: use JSON config if exists, otherwise use env var with defaults
    """
    symbols = {}

    # Get symbols from environment variable
    env_symbols_str = os.getenv("SYMBOLS", "")
    env_symbols = [s.strip() for s in env_symbols_str.split(",") if s.strip()]

    # Load detailed configuration from JSON
    symbol_config = {}
    symbols_json_path = Path("/app/config/symbols.json")
    if symbols_json_path.exists():
        try:
            with open(symbols_json_path) as f:
                config_data = json.load(f)
                for symbol_entry in config_data.get("symbols", []):
                    symbol_config[symbol_entry["symbol"]] = symbol_entry
            logger.info(f"Loaded {len(symbol_config)} symbols from JSON config")
        except Exception as e:
            logger.warning(f"Could not load symbols.json: {e}")

    # Merge: prioritize JSON config, fallback to env var with defaults
    all_symbols = set(env_symbols)
    if symbol_config:
        all_symbols.update(symbol_config.keys())

    for symbol in all_symbols:
        if symbol in symbol_config:
            # Use detailed JSON config
            symbols[symbol] = symbol_config[symbol]
        elif symbol in env_symbols:
            # Create default config from env var
            symbols[symbol] = {
                "symbol": symbol,
                "broker": os.getenv("EXNESS_SERVER", "EXNESS_DEMO"),
                "enabled": True,
                "risk_percent": 1.0,
                "max_positions": 1,
                "min_lot_size": 0.01,
                "max_lot_size": 10.0,
                "description": f"{symbol} (from environment)",
            }

    logger.info(f"Total symbols configured: {len(symbols)}")
    return symbols


def check_mt5_connection():
    """Check if MT5 terminal directory is accessible"""
    mt5_path = os.getenv("MT5_TERMINAL_PATH", "/mt5")
    if os.path.exists(mt5_path):
        logger.info(f"MT5 terminal path accessible: {mt5_path}")
        return True
    else:
        logger.warning(f"MT5 terminal path not found: {mt5_path}")
        return False


def start_bridge_server():
    """Start the bridge server"""
    bridge_port = int(os.getenv("BRIDGE_PORT", 5555))

    # Create socket server
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    try:
        server_socket.bind(("0.0.0.0", bridge_port))
        server_socket.listen(5)
        logger.info(f"Bridge server listening on port {bridge_port}")

        while True:
            try:
                client_socket, address = server_socket.accept()
                logger.info(f"Connection from {address}")
                # Handle client connection (implement your protocol here)
                # For now, just acknowledge and close
                client_socket.send(b"OK\n")
                client_socket.close()
            except Exception as e:
                logger.error(f"Error handling client connection: {e}")
                try:
                    client_socket.close()
                except:
                    pass
    except Exception as e:
        logger.error(f"Bridge server error: {e}")
    finally:
        try:
            server_socket.close()
        except:
            pass


def start_api_server():
    """Start the FastAPI server"""
    import uvicorn
    from fastapi import FastAPI

    app = FastAPI(title="EXNESS Trading Bridge API")

    @app.get("/health")
    async def health_check():
        mt5_connected = check_mt5_connection()
        return {
            "status": "healthy" if mt5_connected else "degraded",
            "mt5_connected": mt5_connected,
        }

    @app.get("/")
    async def root():
        return {"message": "EXNESS Trading Bridge API", "version": "1.0.0"}

    api_port = int(os.getenv("API_PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=api_port)


if __name__ == "__main__":
    logger.info("Starting EXNESS Trading Bridge Service...")

    # Load configuration
    try:
        symbols = load_symbols_config()
        logger.info(f"Loaded {len(symbols)} trading symbols")
    except Exception as e:
        logger.error(f"Failed to load symbols configuration: {e}")
        symbols = {}

    # Check MT5 connection
    mt5_connected = check_mt5_connection()

    # Log configuration summary
    logger.info("Configuration Summary:")
    logger.info(f"  MT5 Account: {os.getenv('MT5_ACCOUNT', 'Not set')}")
    logger.info(f"  MT5 Server: {os.getenv('MT5_SERVER', 'Not set')}")
    logger.info(f"  MT5 Connected: {mt5_connected}")
    logger.info(f"  Bridge Port: {os.getenv('BRIDGE_PORT', '5555')}")
    logger.info(f"  API Port: {os.getenv('API_PORT', '8000')}")
    logger.info(f"  Symbols Count: {len(symbols)}")

    # Start services
    import threading

    # Start bridge server in background thread
    bridge_thread = threading.Thread(target=start_bridge_server, daemon=True)
    bridge_thread.start()

    # Start API server in main thread
    start_api_server()
