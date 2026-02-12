# 🌐 HTTP EA Setup Guide - GenX AI EA v2.01

## 📖 Overview

GenX AI EA v2.01 introduces HTTP-based communication using WebRequest instead of socket-based communication. This provides more reliable, secure, and flexible integration with the GenX Trading Platform AI server.

## 🆕 What's New in v2.01

- **HTTP/WebRequest Communication**: More reliable than socket-based communication
- **Better Error Handling**: Improved error messages and connection management
- **Auto-Reconnection**: Automatically reconnects to the server if connection is lost
- **Heartbeat System**: Regular health checks ensure the EA stays connected
- **JSON Protocol**: Standardized message format for better integration

## 🏗️ Architecture

```
┌─────────────────┐         HTTP          ┌──────────────────┐
│                 │  ◄──────────────►     │                  │
│  MetaTrader 5   │  WebRequest/JSON      │  GenX AI Server  │
│  (GenX AI EA)   │                       │  (FastAPI)       │
│                 │                       │                  │
└─────────────────┘                       └──────────────────┘
```

## 🚀 Installation Steps

### 1. Copy EA to MetaTrader 5

1. Open MetaTrader 5
2. Press `Ctrl + Shift + D` to open the data folder
3. Navigate to `MQL5/Experts/`
4. Copy `GenX_AI_EA.mq5` to this folder
5. Close and restart MetaTrader 5

### 2. Enable WebRequest for the EA

**IMPORTANT**: MT5 requires explicit permission for WebRequest.

1. In MT5, go to **Tools** → **Options**
2. Select the **Expert Advisors** tab
3. Check **"Allow WebRequest for listed URL:"**
4. Add your server URL (e.g., `http://127.0.0.1:9090` or your VPS IP)
5. Click **OK**

### 3. Configure EA Parameters

Drag the EA onto a chart. Configure these parameters:

#### 🔗 Connection Settings
- **AI_Server_URL**: `http://127.0.0.1:9090` (or your server URL)
  - For local testing: `http://127.0.0.1:9090`
  - For VPS: `http://YOUR_VPS_IP:9090`
  - For production: `https://your-domain.com`

#### 🎯 Trading Settings
- **Magic_Number**: `12345` (unique ID for this EA's trades)
- **Default_Lot_Size**: `0.1` (default trade size)
- **Max_Lot_Size**: `1.0` (maximum allowed lot size)
- **Max_Open_Positions**: `10` (maximum concurrent positions)
- **Max_Risk_Per_Trade**: `0.02` (2% risk per trade)

#### ⚙️ System Settings
- **Enable_Auto_Trading**: `true` (enable automatic trading)
- **Heartbeat_Interval**: `30` (seconds between heartbeats)
- **Log_Debug_Info**: `true` (enable debug logging)
- **Request_Timeout**: `5000` (HTTP request timeout in milliseconds)

### 4. Start the AI Server

Ensure the GenX AI Server is running:

```bash
# Start the API server
cd /path/to/A6..9V-GenX_FX.main
python -m uvicorn api.main:app --host 0.0.0.0 --port 9090 --reload
```

Or using Docker:

```bash
docker-compose up
```

### 5. Verify Connection

1. Attach the EA to a chart in MT5
2. Check the **Experts** tab in the Terminal window
3. You should see:
   - "GenX AI EA v2.01 Initializing..."
   - "Successfully connected to AI server at http://..."
   - "GenX AI EA initialized successfully"

## 📡 API Endpoints

The EA communicates with these HTTP endpoints:

### Health Check
- **GET** `/ping`
- Verifies server is running

### Signal Retrieval
- **GET** `/get_signal`
- Retrieves pending trading signals

### EA Registration
- **POST** `/ea_info`
- Registers EA with server, sends metadata

### Heartbeat
- **POST** `/heartbeat`
- Sends periodic health check

### Account Status
- **POST** `/account_status`
- Reports account balance, equity, margin, etc.

### Trade Result
- **POST** `/trade_result`
- Reports trade execution results

## 📊 Message Format

All messages use JSON format:

### Signal Message (from server to EA)
```json
{
  "type": "SIGNAL",
  "data": {
    "signal_id": "SIG_20240101_001",
    "instrument": "EURUSD",
    "action": "BUY",
    "volume": 0.1,
    "stop_loss": 1.0950,
    "take_profit": 1.1050,
    "magic_number": 12345,
    "comment": "GenX AI Signal"
  },
  "timestamp": "2024-01-01T12:00:00Z"
}
```

### Trade Result (from EA to server)
```json
{
  "type": "TRADE_RESULT",
  "data": {
    "signal_id": "SIG_20240101_001",
    "ticket": 123456789,
    "success": true,
    "error_code": 0,
    "error_message": "",
    "execution_price": 1.1000,
    "slippage": 0.0002
  },
  "timestamp": "2024-01-01T12:00:05Z"
}
```

## 🔍 Monitoring

### Check EA Status
View logs in the **Experts** tab of MT5 Terminal window.

### Check Server Status
```bash
# Test connection
curl http://localhost:9090/ping

# Check EA connections
curl http://localhost:9090/ea_status

# View recent trade results
curl http://localhost:9090/trade_results
```

### Debug Mode
Enable `Log_Debug_Info = true` in EA settings to see detailed logs:
- All HTTP requests/responses
- Signal processing
- Trade execution details

## ⚠️ Troubleshooting

### "WebRequest not allowed" Error
1. Go to **Tools** → **Options** → **Expert Advisors**
2. Enable **"Allow WebRequest for listed URL"**
3. Add your server URL
4. Restart MT5

### "Failed to connect to AI server"
1. Verify the server is running: `curl http://localhost:9090/ping`
2. Check firewall settings
3. Verify the URL in EA settings (use IP, not hostname if on same machine)
4. Check server logs for errors

### "No signals received"
1. Check if signals are being generated: `curl http://localhost:9090/ea_status`
2. Verify `Enable_Auto_Trading = true`
3. Check that symbol in MT5 matches signal instrument

### Connection keeps dropping
1. Increase `Request_Timeout` (try 10000ms)
2. Check network stability
3. Verify server isn't restarting frequently
4. Check server logs for errors

## 🔐 Security Best Practices

1. **Use HTTPS in production**: Replace `http://` with `https://`
2. **Firewall**: Only allow connections from known IPs
3. **Authentication**: Add API key authentication (future enhancement)
4. **Network**: Use VPN or private network for EA-Server communication
5. **Monitoring**: Regularly check trade results and logs

## 📈 Testing the EA

### Test Signal Flow

1. Send a test signal to the server:
```bash
curl -X POST http://localhost:9090/send_signal \
  -H "Content-Type: application/json" \
  -d '{
    "signal_id": "TEST_001",
    "instrument": "EURUSD",
    "action": "BUY",
    "volume": 0.01,
    "stop_loss": 1.0950,
    "take_profit": 1.1050
  }'
```

2. The EA should:
   - Retrieve the signal
   - Validate it
   - Execute the trade
   - Report the result

3. Check trade result:
```bash
curl http://localhost:9090/trade_results
```

## 🆚 Comparison: v2.00 vs v2.01

| Feature | v2.00 (Socket) | v2.01 (HTTP) |
|---------|---------------|--------------|
| Communication | TCP Socket | HTTP/WebRequest |
| Protocol | Custom binary | JSON |
| Reliability | Medium | High |
| Firewall-friendly | No | Yes |
| Setup complexity | High | Low |
| Debugging | Difficult | Easy |
| Browser testing | No | Yes (curl, Postman) |
| Auto-reconnect | Limited | Built-in |

## 📚 Additional Resources

- [EA Explained for Beginners](./EA_EXPLAINED_FOR_BEGINNERS.md)
- [System Architecture Guide](./SYSTEM_ARCHITECTURE_GUIDE.md)
- [API Documentation](../api/README.md)
- [Deployment Guide](./DEPLOYMENT.md)

## 💡 Tips

1. **Start with demo account**: Test thoroughly before using real money
2. **Monitor logs**: Keep an eye on the Experts tab
3. **Small lot sizes**: Start with minimum lot size (0.01)
4. **One symbol**: Test with one currency pair first
5. **Backup settings**: Save your EA configuration

## 🆘 Support

If you encounter issues:
1. Check this guide's troubleshooting section
2. Review server and EA logs
3. Open an issue on GitHub
4. Contact support with logs and configuration details

---

**Version**: 2.01  
**Last Updated**: 2024-01-01  
**Author**: GenX Trading Platform Team
