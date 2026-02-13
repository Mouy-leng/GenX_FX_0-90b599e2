"""
Tests for EA API Key Authentication

Tests the new authentication system for EA HTTP endpoints.
"""
import json
import os
from datetime import datetime

import pytest

# Skip tests if FastAPI is not available
try:
    from fastapi.testclient import TestClient
    from api.main import app
    from api.config import settings
    
    FASTAPI_AVAILABLE = True
except ImportError:
    FASTAPI_AVAILABLE = False

pytestmark = pytest.mark.skipif(not FASTAPI_AVAILABLE, reason="FastAPI not available")

# Test API keys
TEST_API_KEY = "test_api_key_12345"
INVALID_API_KEY = "invalid_api_key"


@pytest.fixture(scope="module")
def client():
    """Create test client with mocked settings"""
    if not FASTAPI_AVAILABLE:
        return None
    
    # Set test API key in environment
    os.environ["EA_API_KEY"] = TEST_API_KEY
    
    # Reload settings to pick up the test key
    from api.config import Settings
    test_settings = Settings()
    
    return TestClient(app)


@pytest.fixture
def auth_headers():
    """Headers with valid API key"""
    return {"X-API-Key": TEST_API_KEY}


@pytest.fixture
def invalid_auth_headers():
    """Headers with invalid API key"""
    return {"X-API-Key": INVALID_API_KEY}


class TestPingEndpoint:
    """Test the public /ping endpoint (no auth required)"""
    
    def test_ping_no_auth(self, client):
        """Ping should work without authentication"""
        response = client.get("/ping")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        assert "timestamp" in data


class TestAuthenticationRequired:
    """Test that endpoints require authentication"""
    
    def test_get_signal_without_auth(self, client):
        """get_signal should reject requests without API key"""
        response = client.get("/get_signal")
        assert response.status_code == 401
        assert "Missing API key" in response.json()["detail"]
    
    def test_get_signal_with_invalid_auth(self, client, invalid_auth_headers):
        """get_signal should reject requests with invalid API key"""
        response = client.get("/get_signal", headers=invalid_auth_headers)
        assert response.status_code == 403
        assert "Invalid API key" in response.json()["detail"]
    
    def test_ea_info_without_auth(self, client):
        """ea_info should reject requests without API key"""
        ea_data = {
            "type": "EA_INFO",
            "data": {
                "name": "Test EA",
                "version": "2.01",
                "account": 12345,
                "broker": "Test",
                "symbol": "EURUSD",
                "timeframe": "H1",
                "magic_number": 12345
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        response = client.post("/ea_info", json=ea_data)
        assert response.status_code == 401
    
    def test_heartbeat_without_auth(self, client):
        """heartbeat should reject requests without API key"""
        heartbeat_data = {
            "type": "HEARTBEAT",
            "data": {
                "status": "active",
                "positions": 0,
                "pending_orders": 0,
                "last_signal": "",
                "account": 12345,
                "magic_number": 12345
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        response = client.post("/heartbeat", json=heartbeat_data)
        assert response.status_code == 401
    
    def test_account_status_without_auth(self, client):
        """account_status should reject requests without API key"""
        status_data = {
            "type": "ACCOUNT_STATUS",
            "data": {
                "balance": 10000.00,
                "equity": 10000.00,
                "margin": 0.00,
                "free_margin": 10000.00,
                "margin_level": 0.00,
                "profit": 0.00,
                "open_positions": 0,
                "account": 12345,
                "magic_number": 12345
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        response = client.post("/account_status", json=status_data)
        assert response.status_code == 401
    
    def test_trade_result_without_auth(self, client):
        """trade_result should reject requests without API key"""
        result_data = {
            "type": "TRADE_RESULT",
            "data": {
                "signal_id": "TEST_001",
                "ticket": 123456,
                "success": True,
                "error_code": 0,
                "error_message": "",
                "execution_price": 1.1000,
                "slippage": 0.0001
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        response = client.post("/trade_result", json=result_data)
        assert response.status_code == 401
    
    def test_ea_status_without_auth(self, client):
        """ea_status should reject requests without API key"""
        response = client.get("/ea_status")
        assert response.status_code == 401
    
    def test_send_signal_without_auth(self, client):
        """send_signal should reject requests without API key"""
        signal_data = {
            "signal_id": "TEST_SIG",
            "instrument": "EURUSD",
            "action": "BUY",
            "volume": 0.1
        }
        response = client.post("/send_signal", json=signal_data)
        assert response.status_code == 401
    
    def test_trade_results_without_auth(self, client):
        """trade_results should reject requests without API key"""
        response = client.get("/trade_results")
        assert response.status_code == 401


class TestAuthenticationSuccess:
    """Test that endpoints work with valid authentication"""
    
    def test_get_signal_with_auth(self, client, auth_headers):
        """get_signal should work with valid API key"""
        response = client.get("/get_signal", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        # Should return NO_SIGNAL or SIGNAL
        assert data["type"] in ["NO_SIGNAL", "SIGNAL"]
    
    def test_ea_info_with_auth(self, client, auth_headers):
        """ea_info should work with valid API key"""
        ea_data = {
            "type": "EA_INFO",
            "data": {
                "name": "Auth Test EA",
                "version": "3.00",
                "account": 99999,
                "broker": "Test Broker",
                "symbol": "EURUSD",
                "timeframe": "M15",
                "magic_number": 99999
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        response = client.post("/ea_info", json=ea_data, headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
        assert data["ea_id"] == "99999_99999"
    
    def test_heartbeat_with_auth(self, client, auth_headers):
        """heartbeat should work with valid API key"""
        heartbeat_data = {
            "type": "HEARTBEAT",
            "data": {
                "status": "active",
                "positions": 1,
                "pending_orders": 0,
                "last_signal": "BUY_EURUSD",
                "account": 99999,
                "magic_number": 99999
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        response = client.post("/heartbeat", json=heartbeat_data, headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
    
    def test_account_status_with_auth(self, client, auth_headers):
        """account_status should work with valid API key"""
        status_data = {
            "type": "ACCOUNT_STATUS",
            "data": {
                "balance": 15000.00,
                "equity": 15250.00,
                "margin": 500.00,
                "free_margin": 14750.00,
                "margin_level": 3050.00,
                "profit": 250.00,
                "open_positions": 1,
                "account": 99999,
                "magic_number": 99999
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        response = client.post("/account_status", json=status_data, headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
    
    def test_trade_result_with_auth(self, client, auth_headers):
        """trade_result should work with valid API key"""
        result_data = {
            "type": "TRADE_RESULT",
            "data": {
                "signal_id": "AUTH_TEST_001",
                "ticket": 987654,
                "success": True,
                "error_code": 0,
                "error_message": "",
                "execution_price": 1.0950,
                "slippage": 0.0002
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        response = client.post("/trade_result", json=result_data, headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
    
    def test_ea_status_with_auth(self, client, auth_headers):
        """ea_status should work with valid API key"""
        response = client.get("/ea_status", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "connected_eas" in data
        assert "pending_signals" in data
    
    def test_send_signal_with_auth(self, client, auth_headers):
        """send_signal should work with valid API key"""
        signal_data = {
            "signal_id": "AUTH_SIG_001",
            "instrument": "GBPUSD",
            "action": "SELL",
            "volume": 0.2,
            "stop_loss": 1.2700,
            "take_profit": 1.2600
        }
        response = client.post("/send_signal", json=signal_data, headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
        assert data["signal_id"] == "AUTH_SIG_001"
    
    def test_trade_results_with_auth(self, client, auth_headers):
        """trade_results should work with valid API key"""
        response = client.get("/trade_results", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert "results" in data
        assert "total_count" in data


class TestMultipleAPIKeys:
    """Test support for multiple API keys"""
    
    def test_multiple_keys_config(self):
        """Test that multiple keys can be configured"""
        # Set multiple keys
        os.environ["EA_API_KEYS"] = "key1,key2,key3"
        
        from api.utils.ea_auth import get_valid_ea_api_keys
        valid_keys = get_valid_ea_api_keys()
        
        assert len(valid_keys) >= 3
        assert "key1" in valid_keys
        assert "key2" in valid_keys
        assert "key3" in valid_keys
    
    def test_keys_with_whitespace(self):
        """Test that keys with whitespace are handled correctly"""
        os.environ["EA_API_KEYS"] = "key1, key2 , key3"
        
        from api.utils.ea_auth import get_valid_ea_api_keys
        valid_keys = get_valid_ea_api_keys()
        
        # Should have stripped whitespace
        assert "key1" in valid_keys
        assert "key2" in valid_keys
        assert "key3" in valid_keys
        assert " key2 " not in valid_keys


class TestSecurityHeaders:
    """Test security-related headers"""
    
    def test_missing_key_returns_www_authenticate(self, client):
        """Missing key should return WWW-Authenticate header"""
        response = client.get("/get_signal")
        assert response.status_code == 401
        assert "WWW-Authenticate" in response.headers
        assert response.headers["WWW-Authenticate"] == "ApiKey"
    
    def test_invalid_key_returns_www_authenticate(self, client, invalid_auth_headers):
        """Invalid key should return WWW-Authenticate header"""
        response = client.get("/get_signal", headers=invalid_auth_headers)
        assert response.status_code == 403
        assert "WWW-Authenticate" in response.headers


class TestEndToEndWorkflow:
    """Test complete EA workflow with authentication"""
    
    def test_complete_ea_workflow(self, client, auth_headers):
        """Test a complete EA workflow with authentication"""
        # 1. Register EA
        ea_info = {
            "type": "EA_INFO",
            "data": {
                "name": "Workflow Test EA",
                "version": "4.00",
                "account": 77777,
                "broker": "Workflow Broker",
                "symbol": "USDJPY",
                "timeframe": "H4",
                "magic_number": 77777
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        response = client.post("/ea_info", json=ea_info, headers=auth_headers)
        assert response.status_code == 200
        ea_id = response.json()["ea_id"]
        
        # 2. Send heartbeat
        heartbeat = {
            "type": "HEARTBEAT",
            "data": {
                "status": "active",
                "positions": 0,
                "pending_orders": 0,
                "last_signal": "",
                "account": 77777,
                "magic_number": 77777
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        response = client.post("/heartbeat", json=heartbeat, headers=auth_headers)
        assert response.status_code == 200
        
        # 3. Send signal
        signal = {
            "signal_id": "WORKFLOW_001",
            "instrument": "USDJPY",
            "action": "BUY",
            "volume": 0.1,
            "stop_loss": 145.00,
            "take_profit": 146.00
        }
        response = client.post("/send_signal", json=signal, headers=auth_headers)
        assert response.status_code == 200
        
        # 4. Get signal
        response = client.get("/get_signal", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["type"] == "SIGNAL"
        assert data["data"]["signal_id"] == "WORKFLOW_001"
        
        # 5. Report trade result
        trade_result = {
            "type": "TRADE_RESULT",
            "data": {
                "signal_id": "WORKFLOW_001",
                "ticket": 111222,
                "success": True,
                "error_code": 0,
                "error_message": "",
                "execution_price": 145.50,
                "slippage": 0.0005
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        response = client.post("/trade_result", json=trade_result, headers=auth_headers)
        assert response.status_code == 200
        
        # 6. Check EA status
        response = client.get("/ea_status", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert ea_id in data["eas"]
        
        # 7. Check trade results
        response = client.get("/trade_results", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["total_count"] > 0
