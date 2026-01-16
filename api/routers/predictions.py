from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from typing import List, Optional
import joblib
import asyncio
from datetime import datetime
import logging
import json

from ..main import redis_client

from ..models.schemas import PredictionRequest, PredictionResponse, SignalType, ModelMetrics
from ..config import settings
from ..services.ml_service import MLService
from ..services.data_service import DataService
from ..utils.auth import get_current_user

router = APIRouter(prefix="/predictions", tags=["predictions"])
logger = logging.getLogger(__name__)

# Initialize services
ml_service = MLService()
data_service = DataService()

@router.post("/", response_model=PredictionResponse)
async def create_prediction(
    request: PredictionRequest,
    background_tasks: BackgroundTasks,
    current_user: dict = Depends(get_current_user),
):
    """
    Generates an AI-powered market prediction for a given symbol.

    This endpoint retrieves real-time market data, uses the machine learning
    service to generate a prediction, and logs the prediction in a background task.

    Args:
        request (PredictionRequest): The request body containing the symbol and other
                                     prediction parameters.
        background_tasks (BackgroundTasks): FastAPI's background task runner.
        current_user (dict): The authenticated user.

    Returns:
        PredictionResponse: An object containing the prediction details.

    Raises:
        HTTPException: If data for the symbol cannot be found or if the
                       prediction process fails.
    """
    try:
        # Get real-time market data
        market_data = await data_service.get_realtime_data(request.symbol)
        if market_data is None or market_data.empty:
            raise HTTPException(
                status_code=404, detail=f"No data found for symbol {request.symbol}"
            )

        # Generate prediction
        prediction_result = await ml_service.predict(
            symbol=request.symbol,
            market_data=market_data,
            use_ensemble=request.use_ensemble,
        )

        # Log prediction for future model training
        background_tasks.add_task(
            ml_service.log_prediction, request.symbol, prediction_result
        )

        return PredictionResponse(
            symbol=request.symbol,
            prediction=SignalType(prediction_result["signal"]),
            confidence=prediction_result["confidence"],
            timestamp=datetime.now(),
            features_used=prediction_result["features"],
            model_version=prediction_result["model_version"],
        )

    except Exception as e:
        logger.error(f"Prediction error for {request.symbol}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

@router.get("/batch/{symbols}")
async def batch_predictions(
    symbols: str,
    background_tasks: BackgroundTasks,
    timeframe: str = "1h",
    use_ensemble: bool = True,
    current_user: dict = Depends(get_current_user),
):
    """
    Generates predictions for a batch of symbols concurrently.
    This endpoint is optimized to fetch all market data in a single batch
    to avoid the N+1 problem, making it much more efficient than calling
    the prediction endpoint for each symbol individually.
    Args:
        symbols (str): A comma-separated string of symbols (e.g., "BTCUSDT,ETHUSDT").
        background_tasks (BackgroundTasks): FastAPI's background task runner.
        use_ensemble (bool): Whether to use the ensemble model.
        current_user (dict): The authenticated user.
    Returns:
        dict: A dictionary containing lists of successful predictions and errors.
    """
    symbol_list = [s.strip().upper() for s in symbols.split(",")]
    predictions = []
    errors = []

    # --- Performance Optimization: Batch Data Fetching ---
    # Instead of fetching data for each symbol one by one, we fetch it all
    # in a single batch. This significantly reduces latency and API calls.
    market_data_batch = await data_service.get_batch_realtime_data(
        symbol_list, timeframe
    )

    # --- Concurrently generate predictions ---
    valid_symbols = [
        s for s in symbol_list if s in market_data_batch and not market_data_batch[s].empty
    ]

    prediction_tasks = [
        ml_service.predict(
            symbol=symbol,
            market_data=market_data_batch[symbol],
            use_ensemble=use_ensemble,
        )
        for symbol in valid_symbols
    ]

    results = await asyncio.gather(*prediction_tasks, return_exceptions=True)

    # --- Process results and log predictions ---
    for i, result in enumerate(results):
        symbol = valid_symbols[i]
        if isinstance(result, Exception):
            errors.append({"symbol": symbol, "error": str(result)})
        else:
            # Log prediction in the background
            background_tasks.add_task(ml_service.log_prediction, symbol, result)

            # Create the response object
            predictions.append(
                PredictionResponse(
                    symbol=symbol,
                    prediction=SignalType(result["signal"]),
                    confidence=result["confidence"],
                    timestamp=datetime.now(),
                    features_used=result["features"],
                    model_version=result["model_version"],
                )
            )

    # Report errors for symbols where data could not be fetched
    for symbol in symbol_list:
        if symbol not in valid_symbols:
            errors.append({"symbol": symbol, "error": "Market data not found"})

    return {
        "predictions": predictions,
        "errors": errors,
        "total_processed": len(symbol_list),
    }

@router.get("/model/metrics", response_model=ModelMetrics)
async def get_model_metrics(current_user: dict = Depends(get_current_user)):
    """
    Retrieves the performance metrics of the current prediction model.

    This endpoint is optimized with a Redis cache to avoid re-calculating
    metrics on every request. The cache is invalidated when the model is retrained.

    Args:
        current_user (dict): The authenticated user.

    Returns:
        ModelMetrics: An object containing model performance metrics.

    Raises:
        HTTPException: If the metrics cannot be retrieved.
    """
    # --- Performance: Check for cached metrics first ---
    if redis_client:
        try:
            cached_metrics = redis_client.get("model_metrics")
            if cached_metrics:
                return ModelMetrics(**json.loads(cached_metrics))
        except Exception as e:
            logger.error(f"Redis cache read error: {e}")

    try:
        metrics = await ml_service.get_model_metrics()

        # --- Performance: Cache the new metrics ---
        if redis_client:
            try:
                # Cache for 1 hour
                redis_client.setex("model_metrics", 3600, json.dumps(metrics))
            except Exception as e:
                logger.error(f"Redis cache write error: {e}")

        return ModelMetrics(**metrics)
    except Exception as e:
        logger.error(f"Failed to get model metrics: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to retrieve model metrics")

@router.post("/model/retrain")
async def retrain_model(
    background_tasks: BackgroundTasks,
    symbols: List[str] = ["BTCUSDT", "ETHUSDT"],
    current_user: dict = Depends(get_current_user),
):
    """
    Triggers a background task to retrain the prediction model.

    This endpoint also invalidates the model metrics cache to ensure that
    fresh metrics are served after the model is updated.

    Args:
        background_tasks (BackgroundTasks): FastAPI's background task runner.
        symbols (List[str]): A list of symbols to use for retraining the model.
        current_user (dict): The authenticated user.

    Returns:
        dict: A confirmation message that the retraining has started.

    Raises:
        HTTPException: If the retraining task fails to start.
    """
    try:
        # --- Performance: Invalidate cache before retraining ---
        if redis_client:
            try:
                redis_client.delete("model_metrics")
            except Exception as e:
                logger.error(f"Redis cache delete error: {e}")

        background_tasks.add_task(ml_service.retrain_model, symbols)
        return {"message": "Model retraining started", "symbols": symbols}
    except Exception as e:
        logger.error(f"Failed to start model retraining: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to start model retraining")
