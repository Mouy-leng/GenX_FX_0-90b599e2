"""
Tests for EA HTTP communication endpoints
"""
import json
from datetime import datetime

import pytest

# Skip tests if FastAPI is not available
try:
    from fastapi.testclient import TestClient
    from api.main import app
    FASTAPI_AVAILABLE = True
except ImportError:
    FASTAPI_AVAILABLE = False

if FASTAPI_AVAILABLE:
    client = TestClient(app)
else:
    client = None

pytestmark = pytest.mark.skipif(not FASTAPI_AVAILABLE, reason="FastAPI not available")


def test_ping_endpoint():
    """Test EA ping/health check endpoint"""
    response = client.get("/ping")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "timestamp" in data
    assert "message" in data


def test_get_signal_no_signals():
    """Test get_signal when no signals are pending"""
    response = client.get("/get_signal")
    assert response.status_code == 200
    data = response.json()
    assert data["type"] == "NO_SIGNAL"


def test_ea_info_registration():
    """Test EA registration endpoint"""
    ea_data = {
        "type": "EA_INFO",
        "data": {
            "name": "Test EA",
            "version": "2.01",
            "account": 12345,
            "broker": "Test Broker",
            "symbol": "EURUSD",
            "timeframe": "H1",
            "magic_number": 12345
        },
        "timestamp": datetime.utcnow().isoformat()
    }
    
    response = client.post("/ea_info", json=ea_data)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert "ea_id" in data
    assert data["ea_id"] == "12345_12345"


def test_heartbeat():
    """Test EA heartbeat endpoint"""
    heartbeat_data = {
        "type": "HEARTBEAT",
        "data": {
            "status": "active",
            "positions": 2,
            "pending_orders": 0,
            "last_signal": "2024-01-01T12:00:00",
            "account": 12345,
            "magic_number": 12345
        },
        "timestamp": datetime.utcnow().isoformat()
    }
    
    response = client.post("/heartbeat", json=heartbeat_data)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert "ea_id" in data


def test_account_status():
    """Test account status reporting endpoint"""
    status_data = {
        "type": "ACCOUNT_STATUS",
        "data": {
            "balance": 10000.00,
            "equity": 10150.00,
            "margin": 500.00,
            "free_margin": 9650.00,
            "margin_level": 2030.00,
            "profit": 150.00,
            "open_positions": 2,
            "account": 12345,
            "magic_number": 12345
        },
        "timestamp": datetime.utcnow().isoformat()
    }
    
    response = client.post("/account_status", json=status_data)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert "ea_id" in data


def test_trade_result_success():
    """Test successful trade result reporting"""
    result_data = {
        "type": "TRADE_RESULT",
        "data": {
            "signal_id": "SIG_TEST_001",
            "ticket": 123456789,
            "success": True,
            "error_code": 0,
            "error_message": "",
            "execution_price": 1.1000,
            "slippage": 0.0002
        },
        "timestamp": datetime.utcnow().isoformat()
    }
    
    response = client.post("/trade_result", json=result_data)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"


def test_trade_result_failure():
    """Test failed trade result reporting"""
    result_data = {
        "type": "TRADE_RESULT",
        "data": {
            "signal_id": "SIG_TEST_002",
            "ticket": 0,
            "success": False,
            "error_code": 134,
            "error_message": "Not enough money",
            "execution_price": 0.0,
            "slippage": 0.0
        },
        "timestamp": datetime.utcnow().isoformat()
    }
    
    response = client.post("/trade_result", json=result_data)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"


def test_send_signal():
    """Test sending a signal to EA queue"""
    signal_data = {
        "signal_id": "SIG_TEST_003",
        "instrument": "EURUSD",
        "action": "BUY",
        "volume": 0.1,
        "stop_loss": 1.0950,
        "take_profit": 1.1050
    }
    
    response = client.post("/send_signal", json=signal_data)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["signal_id"] == "SIG_TEST_003"
    
    # Verify signal is now available
    response = client.get("/get_signal")
    assert response.status_code == 200
    data = response.json()
    assert data["type"] == "SIGNAL"
    assert data["data"]["signal_id"] == "SIG_TEST_003"


def test_ea_status():
    """Test EA status monitoring endpoint"""
    response = client.get("/ea_status")
    assert response.status_code == 200
    data = response.json()
    assert "connected_eas" in data
    assert "pending_signals" in data
    assert "trade_results_count" in data
    assert "eas" in data


def test_trade_results_history():
    """Test trade results history endpoint"""
    response = client.get("/trade_results")
    assert response.status_code == 200
    data = response.json()
    assert "results" in data
    assert "total_count" in data
    assert isinstance(data["results"], list)


def test_trade_results_limit():
    """Test trade results with limit parameter"""
    response = client.get("/trade_results?limit=5")
    assert response.status_code == 200
    data = response.json()
    assert len(data["results"]) <= 5


def test_invalid_message_format():
    """Test handling of invalid message format"""
    invalid_data = {
        "invalid_field": "value"
    }
    
    response = client.post("/ea_info", json=invalid_data)
    assert response.status_code == 422  # Validation error


def test_signal_queue_order():
    """Test that signals are retrieved in FIFO order"""
    # Send multiple signals
    signals = [
        {"signal_id": f"SIG_QUEUE_{i}", "instrument": "EURUSD", "action": "BUY", "volume": 0.1}
        for i in range(3)
    ]
    
    for signal in signals:
        client.post("/send_signal", json=signal)
    
    # Retrieve signals and verify order
    retrieved = []
    for _ in range(3):
        response = client.get("/get_signal")
        if response.status_code == 200:
            data = response.json()
            if data.get("type") == "SIGNAL":
                retrieved.append(data["data"]["signal_id"])
    
    # Verify FIFO order
    expected = [s["signal_id"] for s in signals]
    assert retrieved == expected


def test_ea_identification_consistency():
    """Test that EA identification is consistent across endpoints"""
    ea_id = "12345_67890"
    
    # Register EA
    ea_info = {
        "type": "EA_INFO",
        "data": {
            "name": "Test EA",
            "version": "2.01",
            "account": 12345,
            "broker": "Test",
            "symbol": "EURUSD",
            "timeframe": "H1",
            "magic_number": 67890
        },
        "timestamp": datetime.utcnow().isoformat()
    }
    
    response = client.post("/ea_info", json=ea_info)
    assert response.json()["ea_id"] == ea_id
    
    # Send heartbeat
    heartbeat = {
        "type": "HEARTBEAT",
        "data": {
            "status": "active",
            "positions": 0,
            "pending_orders": 0,
            "last_signal": "",
            "account": 12345,
            "magic_number": 67890
        },
        "timestamp": datetime.utcnow().isoformat()
    }
    
    response = client.post("/heartbeat", json=heartbeat)
    assert response.json()["ea_id"] == ea_id
    
    # Check EA status
    response = client.get("/ea_status")
    data = response.json()
    assert ea_id in data["eas"]
