//+------------------------------------------------------------------+
//|                                                     GenX_AI_EA.mq5 |
//|                          Copyright 2024, GenX Trading Platform    |
//|                                   https://github.com/genx-trading |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, GenX Trading Platform"
#property link      "https://github.com/genx-trading"
#property version   "2.01"

//--- Includes
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>

//--- Input parameters
input string   AI_Server_URL = "http://127.0.0.1:9090";  // AI Server URL
input int      Magic_Number = 12345;                      // Magic Number for orders
input double   Default_Lot_Size = 0.1;                   // Default lot size
input double   Max_Lot_Size = 1.0;                       // Maximum lot size
input int      Max_Open_Positions = 10;                  // Maximum open positions
input double   Max_Risk_Per_Trade = 0.02;                // Maximum risk per trade (2%)
input bool     Enable_Auto_Trading = true;                // Enable automatic trading
input int      Heartbeat_Interval = 30;                   // Heartbeat interval in seconds
input bool     Log_Debug_Info = true;                    // Enable debug logging
input int      Request_Timeout = 5000;                    // Request timeout in milliseconds

//--- Global variables
CTrade         trade;
CPositionInfo  position;
COrderInfo     order;

bool           is_connected = false;
datetime       last_heartbeat;
datetime       last_signal_time;
string         last_response = "";

//--- Signal structure
struct TradingSignal {
    string signal_id;
    string instrument;
    string action;          // "BUY", "SELL", "CLOSE", "CLOSE_ALL"
    double volume;
    double stop_loss;
    double take_profit;
    int    magic_number;
    string comment;
    datetime timestamp;
    double confidence;
};

//--- Trade result structure
struct TradeResult {
    string signal_id;
    long   ticket;
    bool   success;
    int    error_code;
    string error_message;
    double execution_price;
    datetime execution_time;
    double slippage;
};

//--- Account status structure
struct AccountStatus {
    double balance;
    double equity;
    double margin;
    double free_margin;
    double margin_level;
    double profit;
    int    open_positions;
    datetime timestamp;
};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    Print("GenX AI EA v2.01 Initializing...");
    
    // Allow WebRequest
    string url = AI_Server_URL;
    if (StringFind(url, "http://") == 0 || StringFind(url, "https://") == 0) {
        // Extract domain for WebRequest
        int start = StringFind(url, "://") + 3;
        int end = StringFind(url, "/", start);
        if (end < 0) end = StringLen(url);
        string domain = StringSubstr(url, start, end - start);
        
        // Attempt a lightweight GET to ensure the host is allowed in WebRequest
        uchar req_body[];
        uchar resp_body[];
        string resp_headers = "";
        int status = WebRequest("GET", url, "", "", Request_Timeout, req_body, 0, resp_body, resp_headers);
        if (status == -1) {
            PrintFormat("WebRequest to %s (host %s) failed, error %d", url, domain, GetLastError());
        }
    }
    
    // Initialize trade class
    trade.SetExpertMagicNumber(Magic_Number);
    trade.SetMarginMode();
    trade.SetTypeFillingBySymbol(Symbol());
    
    // Test connection to AI server
    if (!ConnectToAIServer()) {
        Print("Failed to connect to AI server. EA will retry connection.");
    }
    
    last_heartbeat = TimeCurrent();
    last_signal_time = 0;
    
    Print("GenX AI EA initialized successfully");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Print("GenX AI EA shutting down. Reason: ", reason);
    is_connected = false;
    Print("GenX AI EA deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
    // Check connection status
    if (!is_connected) {
        // Try to reconnect every 30 seconds
        if (TimeCurrent() - last_heartbeat > 30) {
            ConnectToAIServer();
            last_heartbeat = TimeCurrent();
        }
        return;
    }
    
    // Process incoming messages from AI server
    ProcessIncomingMessages();
    
    // Send heartbeat periodically
    if (TimeCurrent() - last_heartbeat >= Heartbeat_Interval) {
        SendHeartbeat();
        SendAccountStatus();
        last_heartbeat = TimeCurrent();
    }
}

//+------------------------------------------------------------------+
//| Connect to AI server                                            |
//+------------------------------------------------------------------+
bool ConnectToAIServer() {
    if (is_connected) return true;
    
    string url = AI_Server_URL + "/ping";
    string headers = "Content-Type: application/json\r\n";
    char post[], result[];
    string result_headers;
    
    int res = WebRequest("GET", url, headers, Request_Timeout, post, result, result_headers);
    
    if (res == -1) {
        int error = GetLastError();
        if (error == 4060) {
            Print("WebRequest not allowed. Add URL to Tools > Options > Expert Advisors > Allow WebRequest");
        } else {
            Print("Failed to connect to AI server. Error: ", error);
        }
        return false;
    }
    
    if (res == 200) {
        is_connected = true;
        Print("Successfully connected to AI server at ", AI_Server_URL);
        SendEAInfo();
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Send EA information to server                                    |
//+------------------------------------------------------------------+
void SendEAInfo() {
    string ea_info = StringFormat(
        "{\"type\":\"EA_INFO\",\"data\":{\"name\":\"GenX AI EA\",\"version\":\"2.01\","
        "\"account\":%lld,\"broker\":\"%s\",\"symbol\":\"%s\",\"timeframe\":\"%s\","
        "\"magic_number\":%d},\"timestamp\":\"%s\"}",
        AccountInfoInteger(ACCOUNT_LOGIN),
        AccountInfoString(ACCOUNT_COMPANY),
        Symbol(),
        PeriodToString(Period()),
        Magic_Number,
        TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS)
    );
    
    SendMessage("/ea_info", ea_info);
}

//+------------------------------------------------------------------+
//| Send heartbeat message                                           |
//+------------------------------------------------------------------+
void SendHeartbeat() {
    string heartbeat = StringFormat(
        "{\"type\":\"HEARTBEAT\",\"data\":{\"status\":\"active\",\"positions\":%d,"
        "\"pending_orders\":%d,\"last_signal\":\"%s\"},\"timestamp\":\"%s\"}",
        PositionsTotal(),
        OrdersTotal(),
        TimeToString(last_signal_time, TIME_DATE | TIME_SECONDS),
        TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS)
    );
    
    SendMessage("/heartbeat", heartbeat);
}

//+------------------------------------------------------------------+
//| Send account status                                              |
//+------------------------------------------------------------------+
void SendAccountStatus() {
    AccountStatus status;
    status.balance = AccountInfoDouble(ACCOUNT_BALANCE);
    status.equity = AccountInfoDouble(ACCOUNT_EQUITY);
    status.margin = AccountInfoDouble(ACCOUNT_MARGIN);
    status.free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    status.margin_level = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
    status.profit = AccountInfoDouble(ACCOUNT_PROFIT);
    status.open_positions = PositionsTotal();
    status.timestamp = TimeCurrent();
    
    string status_msg = StringFormat(
        "{\"type\":\"ACCOUNT_STATUS\",\"data\":{\"balance\":%.2f,\"equity\":%.2f,"
        "\"margin\":%.2f,\"free_margin\":%.2f,\"margin_level\":%.2f,\"profit\":%.2f,"
        "\"open_positions\":%d},\"timestamp\":\"%s\"}",
        status.balance, status.equity, status.margin, status.free_margin,
        status.margin_level, status.profit, status.open_positions,
        TimeToString(status.timestamp, TIME_DATE | TIME_SECONDS)
    );
    
    SendMessage("/account_status", status_msg);
}

//+------------------------------------------------------------------+
//| Process incoming messages from AI server                        |
//+------------------------------------------------------------------+
void ProcessIncomingMessages() {
    string url = AI_Server_URL + "/get_signal";
    string headers = "Content-Type: application/json\r\n";
    char post[], result[];
    string result_headers;
    
    int res = WebRequest("GET", url, headers, Request_Timeout, post, result, result_headers);
    
    if (res == 200) {
        string response = CharArrayToString(result);
        last_response = response;
        
        if (Log_Debug_Info) {
            Print("Received message: ", response);
        }
        
        ProcessMessage(response);
    } else if (res != -1) {
        if (Log_Debug_Info) {
            Print("No new signals (HTTP ", res, ")");
        }
    }
}

//+------------------------------------------------------------------+
//| Process individual message                                       |
//+------------------------------------------------------------------+
void ProcessMessage(string message) {
    // Simple JSON parsing for message type
    if (StringFind(message, "\"type\":\"SIGNAL\"") >= 0) {
        TradingSignal signal;
        if (ParseTradingSignal(message, signal)) {
            ExecuteTradingSignal(signal);
        }
    }
    else if (StringFind(message, "\"type\":\"COMMAND\"") >= 0) {
        ProcessCommand(message);
    }
    else {
        if (Log_Debug_Info) {
            Print("Unknown message type received: ", message);
        }
    }
}

//+------------------------------------------------------------------+
//| Parse trading signal from JSON message                          |
//+------------------------------------------------------------------+
bool ParseTradingSignal(string message, TradingSignal &signal) {
    // Simple JSON parsing - in production, use a proper JSON library
    int start, end;
    
    // Extract signal_id
    start = StringFind(message, "\"signal_id\":\"") + 13;
    end = StringFind(message, "\"", start);
    if (start >= 13 && end > start) {
        signal.signal_id = StringSubstr(message, start, end - start);
    }
    
    // Extract instrument
    start = StringFind(message, "\"instrument\":\"") + 14;
    end = StringFind(message, "\"", start);
    if (start >= 14 && end > start) {
        signal.instrument = StringSubstr(message, start, end - start);
    }
    
    // Extract action
    start = StringFind(message, "\"action\":\"") + 10;
    end = StringFind(message, "\"", start);
    if (start >= 10 && end > start) {
        signal.action = StringSubstr(message, start, end - start);
    }
    
    // Extract volume
    start = StringFind(message, "\"volume\":") + 9;
    end = StringFind(message, ",", start);
    if (end < 0) end = StringFind(message, "}", start);
    if (start >= 9 && end > start) {
        string vol_str = StringSubstr(message, start, end - start);
        signal.volume = StringToDouble(vol_str);
    }
    
    // Extract stop_loss (optional)
    start = StringFind(message, "\"stop_loss\":") + 12;
    if (start >= 12) {
        end = StringFind(message, ",", start);
        if (end < 0) end = StringFind(message, "}", start);
        if (end > start) {
            string sl_str = StringSubstr(message, start, end - start);
            if (sl_str != "null" && sl_str != "") {
                signal.stop_loss = StringToDouble(sl_str);
            }
        }
    }
    
    // Extract take_profit (optional)
    start = StringFind(message, "\"take_profit\":") + 15;
    if (start >= 15) {
        end = StringFind(message, ",", start);
        if (end < 0) end = StringFind(message, "}", start);
        if (end > start) {
            string tp_str = StringSubstr(message, start, end - start);
            if (tp_str != "null" && tp_str != "") {
                signal.take_profit = StringToDouble(tp_str);
            }
        }
    }
    
    // Set defaults
    signal.magic_number = Magic_Number;
    signal.comment = "GenX AI Signal";
    signal.timestamp = TimeCurrent();
    
    // Validate signal
    if (signal.signal_id == "" || signal.instrument == "" || signal.action == "") {
        Print("Invalid signal received - missing required fields");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Execute trading signal                                           |
//+------------------------------------------------------------------+
void ExecuteTradingSignal(TradingSignal &signal) {
    Print("Executing signal: ", signal.action, " ", signal.instrument, " ", signal.volume);
    
    last_signal_time = TimeCurrent();
    TradeResult result;
    result.signal_id = signal.signal_id;
    result.success = false;
    result.execution_time = TimeCurrent();
    result.ticket = 0;
    result.error_code = 0;
    result.error_message = "";
    result.execution_price = 0.0;
    result.slippage = 0.0;
    
    // Validate signal before execution
    if (!ValidateSignal(signal)) {
        result.error_message = "Signal validation failed";
        SendTradeResult(result);
        return;
    }
    
    // Execute based on action
    if (signal.action == "BUY") {
        result.success = ExecuteBuyOrder(signal, result);
    }
    else if (signal.action == "SELL") {
        result.success = ExecuteSellOrder(signal, result);
    }
    else if (signal.action == "CLOSE") {
        result.success = ClosePosition(signal.instrument, result);
    }
    else if (signal.action == "CLOSE_ALL") {
        result.success = CloseAllPositions(result);
    }
    else {
        result.error_message = "Unknown action: " + signal.action;
    }
    
    // Send result back to AI server
    SendTradeResult(result);
}

//+------------------------------------------------------------------+
//| Validate trading signal                                          |
//+------------------------------------------------------------------+
bool ValidateSignal(TradingSignal &signal) {
    // Check if auto trading is enabled
    if (!Enable_Auto_Trading) {
        Print("Auto trading is disabled");
        return false;
    }
    
    // Check symbol
    if (signal.instrument != Symbol()) {
        Print("Signal for different symbol: ", signal.instrument, " (current: ", Symbol(), ")");
        return false;
    }
    
    // Check volume limits
    if (signal.volume <= 0 || signal.volume > Max_Lot_Size) {
        Print("Invalid volume: ", signal.volume, " (max: ", Max_Lot_Size, ")");
        return false;
    }
    
    // Check maximum positions
    if (PositionsTotal() >= Max_Open_Positions && 
        (signal.action == "BUY" || signal.action == "SELL")) {
        Print("Maximum positions reached: ", PositionsTotal());
        return false;
    }
    
    // Check account equity for risk management
    double account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double position_value = signal.volume * SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE) * 
                           SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    
    if (position_value > account_equity * Max_Risk_Per_Trade) {
        Print("Position size exceeds risk limit");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Execute buy order                                                |
//+------------------------------------------------------------------+
bool ExecuteBuyOrder(TradingSignal &signal, TradeResult &result) {
    double ask = SymbolInfoDouble(signal.instrument, SYMBOL_ASK);
    double sl = (signal.stop_loss > 0) ? signal.stop_loss : 0;
    double tp = (signal.take_profit > 0) ? signal.take_profit : 0;
    
    if (!trade.Buy(signal.volume, signal.instrument, ask, sl, tp, signal.comment)) {
        result.error_code = (int)trade.ResultRetcode();
        result.error_message = "Buy order failed: " + IntegerToString(result.error_code);
        Print(result.error_message);
        return false;
    }
    
    result.ticket = trade.ResultOrder();
    result.execution_price = trade.ResultPrice();
    result.slippage = MathAbs(result.execution_price - ask);
    
    Print("Buy order executed successfully. Ticket: ", IntegerToString(result.ticket), 
          " Price: ", DoubleToString(result.execution_price, 5));
    
    return true;
}

//+------------------------------------------------------------------+
//| Execute sell order                                               |
//+------------------------------------------------------------------+
bool ExecuteSellOrder(TradingSignal &signal, TradeResult &result) {
    double bid = SymbolInfoDouble(signal.instrument, SYMBOL_BID);
    double sl = (signal.stop_loss > 0) ? signal.stop_loss : 0;
    double tp = (signal.take_profit > 0) ? signal.take_profit : 0;
    
    if (!trade.Sell(signal.volume, signal.instrument, bid, sl, tp, signal.comment)) {
        result.error_code = (int)trade.ResultRetcode();
        result.error_message = "Sell order failed: " + IntegerToString(result.error_code);
        Print(result.error_message);
        return false;
    }
    
    result.ticket = trade.ResultOrder();
    result.execution_price = trade.ResultPrice();
    result.slippage = MathAbs(result.execution_price - bid);
    
    Print("Sell order executed successfully. Ticket: ", IntegerToString(result.ticket), 
          " Price: ", DoubleToString(result.execution_price, 5));
    
    return true;
}

//+------------------------------------------------------------------+
//| Close position for specific symbol                              |
//+------------------------------------------------------------------+
bool ClosePosition(string symbol, TradeResult &result) {
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        if (position.SelectByIndex(i)) {
            if (position.Symbol() == symbol && position.Magic() == Magic_Number) {
                if (trade.PositionClose(position.Ticket())) {
                    result.ticket = position.Ticket();
                    result.execution_price = trade.ResultPrice();
                    Print("Position closed successfully. Ticket: ", IntegerToString(result.ticket));
                    return true;
                } else {
                    result.error_code = (int)trade.ResultRetcode();
                    result.error_message = "Failed to close position: " + IntegerToString(result.error_code);
                    Print(result.error_message);
                    return false;
                }
            }
        }
    }
    
    result.error_message = "No position found for symbol: " + symbol;
    Print(result.error_message);
    return false;
}

//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
bool CloseAllPositions(TradeResult &result) {
    int closed_count = 0;
    
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        if (position.SelectByIndex(i)) {
            if (position.Magic() == Magic_Number) {
                if (trade.PositionClose(position.Ticket())) {
                    closed_count++;
                    Print("Position closed. Ticket: ", IntegerToString(position.Ticket()));
                }
            }
        }
    }
    
    if (closed_count > 0) {
        result.execution_price = 0.0; // Multiple positions
        result.success = true;
        Print("Closed ", IntegerToString(closed_count), " positions");
        return true;
    } else {
        result.error_message = "No positions to close";
        result.success = false;
        return false;
    }
}

//+------------------------------------------------------------------+
//| Process command from AI server                                  |
//+------------------------------------------------------------------+
void ProcessCommand(string message) {
    if (StringFind(message, "\"command\":\"GET_STATUS\"") >= 0) {
        SendAccountStatus();
    }
    else if (StringFind(message, "\"command\":\"CLOSE_ALL\"") >= 0) {
        TradeResult result;
        result.signal_id = "COMMAND_CLOSE_ALL";
        result.success = CloseAllPositions(result);
        SendTradeResult(result);
    }
    else if (StringFind(message, "\"command\":\"PING\"") >= 0) {
        SendHeartbeat();
    }
    else {
        Print("Unknown command received: ", message);
    }
}

//+------------------------------------------------------------------+
//| Send trade result to AI server                                  |
//+------------------------------------------------------------------+
void SendTradeResult(TradeResult &result) {
    string result_msg = StringFormat(
        "{\"type\":\"TRADE_RESULT\",\"data\":{\"signal_id\":\"%s\",\"ticket\":%lld,"
        "\"success\":%s,\"error_code\":%d,\"error_message\":\"%s\","
        "\"execution_price\":%.5f,\"slippage\":%.5f},\"timestamp\":\"%s\"}",
        result.signal_id,
        result.ticket,
        result.success ? "true" : "false",
        result.error_code,
        result.error_message,
        result.execution_price,
        result.slippage,
        TimeToString(result.execution_time, TIME_DATE | TIME_SECONDS)
    );
    
    SendMessage("/trade_result", result_msg);
}

//+------------------------------------------------------------------+
//| Send message to AI server via HTTP POST                          |
//+------------------------------------------------------------------+
void SendMessage(string endpoint, string message) {
    if (!is_connected) {
        Print("Cannot send message - not connected to AI server");
        return;
    }
    
    string url = AI_Server_URL + endpoint;
    string headers = "Content-Type: application/json\r\n";
    char post[], result[];
    string result_headers;
    
    StringToCharArray(message, post, 0, WHOLE_ARRAY, CP_UTF8);
    
    int res = WebRequest("POST", url, headers, Request_Timeout, post, result, result_headers);
    
    if (res == -1) {
        int error = GetLastError();
        Print("Failed to send message. Error: ", error);
        if (error == 4060) {
            is_connected = false;
        }
        return;
    }
    
    if (Log_Debug_Info) {
        Print("Message sent: ", message);
    }
}

//+------------------------------------------------------------------+
//| Convert period to string                                         |
//+------------------------------------------------------------------+
string PeriodToString(ENUM_TIMEFRAMES period) {
    switch(period) {
        case PERIOD_M1:  return "M1";
        case PERIOD_M5:  return "M5";
        case PERIOD_M15: return "M15";
        case PERIOD_M30: return "M30";
        case PERIOD_H1:  return "H1";
        case PERIOD_H4:  return "H4";
        case PERIOD_D1:  return "D1";
        case PERIOD_W1:  return "W1";
        case PERIOD_MN1: return "MN1";
        default:         return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
    // Additional periodic tasks if needed
}

