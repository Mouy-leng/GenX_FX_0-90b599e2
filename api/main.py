from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
import sqlite3
import os
from datetime import datetime
import time
import json

app = FastAPI(
    title="GenX-FX Trading Platform API",
    description="Trading platform with ML-powered predictions",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Performance Optimization: In-Memory Cache for Monitoring Endpoint ---
# To avoid frequent and slow disk I/O on the monitoring endpoint, we use a
# simple in-memory cache. The cache stores the contents of system_metrics.json
# for a short duration, reducing latency and system load.
_monitor_cache = None
_monitor_cache_timestamp = 0
CACHE_DURATION_SECONDS = 1  # Cache metrics for 1 second


# --------------------------------------------------------------------------
# Dependency Injection for Database Connection
# --------------------------------------------------------------------------
# To ensure thread safety with SQLite, we use FastAPI's dependency injection
# system to manage the database connection. A new connection is created for
# each request and closed when the request is complete. This is a safe and
# standard pattern for managing resources in a web application.
# --------------------------------------------------------------------------

def get_db():
    """
    FastAPI dependency to get a database connection for each request.
    """
    db = sqlite3.connect("genxdb_fx.db")
    db.row_factory = sqlite3.Row
    try:
        yield db
    finally:
        db.close()

@app.get("/")
async def root():
    """
    Root endpoint for the API.

    Provides basic information about the API, including its name, version,
    status, and repository URL.

    Returns:
        dict: A dictionary containing API information.
    """
    return {
        "message": "GenX-FX Trading Platform API",
        "version": "1.0.0",
        "status": "active",
        "docs": "/docs",
        "github": "Mouy-leng",
        "repository": "https://github.com/Mouy-leng/GenX_FX.git",
    }

@app.get("/health")
async def health_check(db: sqlite3.Connection = Depends(get_db)):
    """
    Performs a health check on the API and its database connection.

    Attempts to connect to the SQLite database and execute a simple query.

    Returns:
        dict: A dictionary indicating the health status. 'healthy' if the
              database connection is successful, 'unhealthy' otherwise.
    """
    try:
        # --- Use the DB connection from the dependency ---
        cursor = db.cursor()
        cursor.execute("SELECT 1")

        return {
            "status": "healthy",
            "database": "connected",
            "timestamp": datetime.now().isoformat(),
            "services": {
                "ml_service": "active",
                "data_service": "active"
            }
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.now().isoformat(),
            "services": {
                "ml_service": "inactive",
                "data_service": "inactive"
            }
        }

@app.get("/api/v1/health")
async def api_health_check():
    """
    Provides a health check for the v1 API services.

    Returns a hardcoded status indicating that the main services are active.

    Returns:
        dict: A dictionary with the health status of internal services.
    """
    return {
        "status": "healthy",
        "services": {"ml_service": "active", "data_service": "active"},
        "timestamp": datetime.now().isoformat(),
    }

@app.post("/api/v1/predictions")
async def get_predictions(request: dict):
    """
    Endpoint to get trading predictions.

    Currently returns a placeholder response.

    Returns:
        dict: A dictionary containing an empty list of predictions.
    """
    return {
        "predictions": [],
        "status": "ready",
        "timestamp": datetime.now().isoformat(),
    }

@app.get("/trading-pairs")
async def get_trading_pairs(db: sqlite3.Connection = Depends(get_db)):
    """
    Retrieves a list of active trading pairs from the database.

    Connects to the SQLite database and fetches all pairs marked as active.

    Returns:
        dict: A dictionary containing a list of trading pairs or an error message.
    """
    try:
        # --- Use the DB connection from the dependency ---
        cursor = db.cursor()
        cursor.execute(
            "SELECT symbol, base_currency, quote_currency FROM trading_pairs WHERE is_active = 1"
        )
        pairs = cursor.fetchall()

        return {
            "trading_pairs": [
                {
                    "symbol": pair["symbol"],
                    "base_currency": pair["base_currency"],
                    "quote_currency": pair["quote_currency"],
                }
                for pair in pairs
            ]
        }
    except Exception as e:
        return {"error": str(e)}

@app.get("/users")
async def get_users(db: sqlite3.Connection = Depends(get_db)):
    """
    Retrieves a list of users from the database.

    Connects to the SQLite database and fetches user information.

    Returns:
        dict: A dictionary containing a list of users or an error message.
    """
    try:
        # --- Use the DB connection from the dependency ---
        cursor = db.cursor()
        cursor.execute("SELECT username, email, is_active FROM users")
        users = cursor.fetchall()

        return {
            "users": [
                {
                    "username": user["username"],
                    "email": user["email"],
                    "is_active": bool(user["is_active"])
                }
                for user in users
            ]
        }
    except Exception as e:
        return {"error": str(e)}

@app.get("/mt5-info")
async def get_mt5_info():
    """
    Provides hardcoded information about the MT5 connection.

    Returns:
        dict: A dictionary with static MT5 login and server details.
    """
    return {"login": "279023502", "server": "Exness-MT5Trial8", "status": "configured"}

@app.get("/api/v1/monitor")
async def get_monitoring_data():
    """
    Retrieves the latest system metrics from the monitoring service.

    This endpoint is optimized with an in-memory cache to reduce disk I/O
    and improve response time. It serves a cached version of the metrics if
    the cache is less than CACHE_DURATION_SECONDS old.

    Returns:
        dict: A dictionary containing the latest system metrics, or an
              error message if the metrics are not available.
    """
    global _monitor_cache, _monitor_cache_timestamp

    # --- Check if the cache is still valid ---
    current_time = time.time()
    if _monitor_cache and (current_time - _monitor_cache_timestamp < CACHE_DURATION_SECONDS):
        return _monitor_cache

    # --- If cache is invalid, read from disk and update cache ---
    try:
        with open("system_metrics.json", "r") as f:
            metrics = json.load(f)

        # --- Update cache and timestamp ---
        _monitor_cache = metrics
        _monitor_cache_timestamp = current_time

        return metrics
    except FileNotFoundError:
        return {"error": "Monitoring data not available yet."}
    except Exception as e:
        return {"error": str(e)}

@app.get("/monitor")
async def serve_monitoring_dashboard():
    """
    Serves the monitoring dashboard HTML file.

    Returns:
        FileResponse: The HTML file for the monitoring dashboard.
    """
    return FileResponse("monitoring_dashboard.html")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
