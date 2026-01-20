from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
import sqlite3
import os
from datetime import datetime
import json
import redis.asyncio as redis
import logging

app = FastAPI(
    title="GenX-FX Trading Platform API",
    description="Trading platform with ML-powered predictions",
    version="1.0.0",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Performance Optimization: Redis Cache for Monitoring Endpoint ---
# To avoid frequent and slow disk I/O on the monitoring endpoint, we use a
# Redis cache. This ensures that the cache is shared across all worker
# processes, which is not the case with a simple in-memory global variable.
# It also provides more robust caching with a configurable expiration time.
#
# The Redis connection details are retrieved from environment variables,
# with sensible defaults for local development.
# --------------------------------------------------------------------------
REDIS_HOST = os.environ.get("REDIS_HOST", "localhost")
REDIS_PORT = int(os.environ.get("REDIS_PORT", 6379))
CACHE_DURATION_SECONDS = 5  # Cache metrics for 5 seconds

# --- Set up basic logging ---
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)

redis_client = None

@app.on_event("startup")
async def startup_event():
    global redis_client
    try:
        redis_client = await redis.from_url(
            f"redis://{REDIS_HOST}:{REDIS_PORT}", encoding="utf-8", decode_responses=True
        )
        await redis_client.ping()
        logging.info("Successfully connected to Redis.")
    except Exception as e:
        logging.error(
            f"Could not connect to Redis: {e}. Caching will be disabled."
        )
        redis_client = None

@app.on_event("shutdown")
async def shutdown_event():
    if redis_client:
        await redis_client.close()


# --------------------------------------------------------------------------
# Performance Optimization: In-Memory Cache for Static HTML
# --------------------------------------------------------------------------
# To avoid reading the same static HTML file from disk on every request,
# we cache its content in a global variable on application startup. This
# reduces disk I/O and improves the response time for the monitoring dashboard.
# --------------------------------------------------------------------------
MONITORING_DASHBOARD_CACHE = None


@app.on_event("startup")
def cache_monitoring_dashboard():
    """
    Loads the monitoring dashboard HTML into an in-memory cache at startup.
    """
    global MONITORING_DASHBOARD_CACHE
    try:
        with open("monitoring_dashboard.html", "r") as f:
            MONITORING_DASHBOARD_CACHE = f.read()
        logging.info("Successfully cached monitoring_dashboard.html.")
    except FileNotFoundError:
        logging.error(
            "monitoring_dashboard.html not found. "
            "The /monitor endpoint will be disabled."
        )
        MONITORING_DASHBOARD_CACHE = (
            "<h1>Error: Monitoring dashboard not found.</h1>"
        )
    except Exception as e:
        logging.error(f"An error occurred while caching the dashboard: {e}")
        MONITORING_DASHBOARD_CACHE = (
            "<h1>Error: Could not load monitoring dashboard.</h1>"
        )


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
    # --- Performance: Use Redis cache if available ---
    # This endpoint returns a static JSON response. Caching it reduces
    # processing time for frequent requests, such as from health checkers.
    if redis_client:
        try:
            cached_root = await redis_client.get("root_cache")
            if cached_root:
                return json.loads(cached_root)
        except Exception as e:
            logging.error(f"Redis connection error: {e}. Performing live query.")

    response = {
        "message": "GenX-FX Trading Platform API",
        "version": "1.0.0",
        "status": "active",
        "docs": "/docs",
        "github": "Mouy-leng",
        "repository": "https://github.com/Mouy-leng/GenX_FX.git",
    }

    # --- Update Redis cache if available ---
    if redis_client:
        try:
            # Cache for 1 minute (60 seconds)
            await redis_client.setex("root_cache", 60, json.dumps(response))
        except Exception as e:
            logging.error(f"Could not write to Redis cache: {e}.")

    return response


@app.get("/health")
async def health_check(db: sqlite3.Connection = Depends(get_db)):
    """
    Performs a health check on the API and its database connection.

    Attempts to connect to the SQLite database and execute a simple query.
    This endpoint is optimized with a short-lived Redis cache to reduce
    database load from frequent health checks.

    Returns:
        dict: A dictionary indicating the health status. 'healthy' if the
              database connection is successful, 'unhealthy' otherwise.
    """
    # --- Performance: Use Redis cache if available ---
    if redis_client:
        try:
            cached_health = await redis_client.get("health_check_status")
            if cached_health:
                return json.loads(cached_health)
        except Exception as e:
            logging.error(
                f"Redis connection error: {e}. Performing live check."
            )

    try:
        # --- Use the DB connection from the dependency ---
        cursor = db.cursor()
        cursor.execute("SELECT 1")

        healthy_response = {
            "status": "healthy",
            "database": "connected",
            "timestamp": datetime.now().isoformat(),
            "services": {"ml_service": "active", "data_service": "active"},
        }

        # --- Update Redis cache if available ---
        if redis_client:
            try:
                await redis_client.setex(
                    "health_check_status", 10, json.dumps(healthy_response)
                )
            except Exception as e:
                logging.error(f"Could not write to Redis cache: {e}.")

        return healthy_response

    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.now().isoformat(),
            "services": {"ml_service": "inactive", "data_service": "inactive"},
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

    This endpoint is optimized with a Redis cache to reduce database load, as
    the list of trading pairs does not change frequently. The cache expires
    every hour.

    Returns:
        dict: A dictionary containing a list of trading pairs or an error
              message.
    """
    # --- Performance: Use Redis cache if available ---
    if redis_client:
        try:
            cached_pairs = await redis_client.get("trading_pairs_cache")
            if cached_pairs:
                return json.loads(cached_pairs)
        except Exception as e:
            logging.error(
                f"Redis connection error: {e}. Performing live query."
            )

    try:
        # --- Use the DB connection from the dependency ---
        cursor = db.cursor()
        cursor.execute(
            "SELECT symbol, base_currency, quote_currency "
            "FROM trading_pairs WHERE is_active = 1"
        )
        pairs = cursor.fetchall()

        response = {
            "trading_pairs": [
                {
                    "symbol": pair["symbol"],
                    "base_currency": pair["base_currency"],
                    "quote_currency": pair["quote_currency"],
                }
                for pair in pairs
            ]
        }

        # --- Update Redis cache if available ---
        if redis_client:
            try:
                # Cache for 1 hour (3600 seconds)
                await redis_client.setex(
                    "trading_pairs_cache", 3600, json.dumps(response)
                )
            except Exception as e:
                logging.error(f"Could not write to Redis cache: {e}.")

        return response
    except Exception as e:
        return {"error": str(e)}


@app.get("/users", deprecated=True)
async def get_users_deprecated(db: sqlite3.Connection = Depends(get_db)):
    """
    Retrieves a list of users from the database.

    **Deprecated:** This endpoint is not recommended for new use. Please use
    the paginated `/api/v2/users` endpoint instead.

    Connects to the SQLite database and fetches user information.

    Returns:
        dict: A dictionary containing a list of users or an error message.
    """
    # --- Performance Warning: This endpoint is not paginated ---
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
                    "is_active": bool(user["is_active"]),
                }
                for user in users
            ]
        }
    except Exception as e:
        return {"error": str(e)}


@app.get("/api/v2/users")
async def get_users(
    db: sqlite3.Connection = Depends(get_db), skip: int = 0, limit: int = 10
):
    """
    Retrieves a list of users from the database with pagination.

    Connects to the SQLite database and fetches user information.

    - **skip**: The number of records to skip (for pagination).
    - **limit**: The maximum number of records to return.

    Returns:
        dict: A dictionary containing a list of users or an error message.
    """
    # --- Performance: Add pagination ---
    try:
        # --- Use the DB connection from the dependency ---
        cursor = db.cursor()
        cursor.execute(
            "SELECT username, email, is_active FROM users LIMIT ? OFFSET ?",
            (limit, skip),
        )
        users = cursor.fetchall()

        return {
            "users": [
                {
                    "username": user["username"],
                    "email": user["email"],
                    "is_active": bool(user["is_active"]),
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
    # --- Performance: Use Redis cache for static data ---
    # This endpoint returns static data. Caching it reduces the overhead of
    # JSON serialization and request processing on every call.
    if redis_client:
        try:
            cached_info = await redis_client.get("mt5_info_cache")
            if cached_info:
                return json.loads(cached_info)
        except Exception as e:
            logging.error(f"Redis connection error: {e}. Serving live data.")

    response = {
        "login": "279023502",
        "server": "Exness-MT5Trial8",
        "status": "configured",
    }

    # --- Update Redis cache if available ---
    if redis_client:
        try:
            # Cache for 1 hour (3600 seconds)
            await redis_client.setex("mt5_info_cache", 3600, json.dumps(response))
        except Exception as e:
            logging.error(f"Could not write to Redis cache: {e}.")

    return response


@app.get("/api/v1/monitor")
async def get_monitoring_data():
    """
    Retrieves the latest system metrics directly from the Redis cache.

    This endpoint is optimized to serve metrics from an in-memory Redis cache,
    which is populated by the `system_monitor.py` service. This approach
    avoids any disk I/O in the API, making it highly performant.

    Returns:
        dict: A dictionary containing the latest system metrics, or an
              error message if the metrics are not available in the cache.
    """
    if not redis_client:
        return {
            "error": "Redis is not connected; monitoring data is unavailable."
        }

    try:
        cached_metrics = await redis_client.get("system_metrics")
        if cached_metrics:
            return json.loads(cached_metrics)
        else:
            return {"error": "Monitoring data not available yet."}
    except Exception as e:
        logging.error(f"Redis connection error: {e}")
        return {"error": "Could not connect to Redis for monitoring data."}


@app.get("/monitor")
async def serve_monitoring_dashboard():
    """
    Serves the monitoring dashboard HTML file from an in-memory cache.

    This endpoint is optimized to serve the dashboard from a global variable,
    reducing disk I/O and improving performance.

    Returns:
        HTMLResponse: The HTML content of the monitoring dashboard.
    """
    return HTMLResponse(content=MONITORING_DASHBOARD_CACHE)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port="8080")
