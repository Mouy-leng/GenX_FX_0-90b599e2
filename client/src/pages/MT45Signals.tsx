import { useState, useEffect } from 'react'
import { SignalCard } from '../components/SignalCard'
import { StatusCard } from '../components/StatusCard'
import { ConfigPanel, ConfigItem } from '../components/ConfigPanel'
import { API_CONFIG } from '../config'

interface Signal {
  id?: string
  symbol: string
  entry: number
  target: number
  stopLoss: number
  status: 'active' | 'completed' | 'cancelled'
  confidence: number
  timestamp?: string
}

interface SignalStats {
  totalSignals: number
  activeSignals: number
  completedSignals: number
  successRate: number
}

export function MT45Signals() {
  const [signals, setSignals] = useState<Signal[]>([])
  const [stats, setStats] = useState<SignalStats>({
    totalSignals: 0,
    activeSignals: 0,
    completedSignals: 0,
    successRate: 0,
  })
  const [isConnected, setIsConnected] = useState(false)

  useEffect(() => {
    const API_BASE = API_CONFIG.PYTHON_API_URL

    // Fetch signals
    const fetchSignals = () => {
      fetch(`${API_BASE}/api/v1/signals`)
        .then(res => res.json())
        .then(() => {
          // Mock data for demonstration (API data not used yet)
          const mockSignals: Signal[] = [
            {
              id: '1',
              symbol: 'XAUUSD',
              entry: 2045.50,
              target: 2055.00,
              stopLoss: 2040.00,
              status: 'active',
              confidence: 85,
              timestamp: new Date().toISOString(),
            },
            {
              id: '2',
              symbol: 'EURUSD',
              entry: 1.0850,
              target: 1.0900,
              stopLoss: 1.0820,
              status: 'active',
              confidence: 78,
              timestamp: new Date(Date.now() - 3600000).toISOString(),
            },
            {
              id: '3',
              symbol: 'GBPUSD',
              entry: 1.2650,
              target: 1.2700,
              stopLoss: 1.2620,
              status: 'completed',
              confidence: 92,
              timestamp: new Date(Date.now() - 7200000).toISOString(),
            },
          ]
          setSignals(mockSignals)
          setIsConnected(true)

          // Calculate stats
          const active = mockSignals.filter(s => s.status === 'active').length
          const completed = mockSignals.filter(s => s.status === 'completed').length
          setStats({
            totalSignals: mockSignals.length,
            activeSignals: active,
            completedSignals: completed,
            successRate: 87.5,
          })
        })
        .catch(err => {
          console.error('Failed to fetch signals:', err)
          setIsConnected(false)
        })
    }

    fetchSignals()
    const interval = setInterval(fetchSignals, 10000) // Update every 10s

    return () => clearInterval(interval)
  }, [])

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-4xl font-bold mb-8 text-gray-900">
          📡 MT4/MT5 Trading Signals
        </h1>

        <div className="grid lg:grid-cols-3 gap-6 mb-6">
          <StatusCard
            title="Signal Service"
            status={isConnected ? 'healthy' : 'unhealthy'}
            icon={<span className="text-2xl">📊</span>}
          >
            <div className="flex justify-between">
              <span className="text-gray-600">Connection:</span>
              <span className="font-semibold">{isConnected ? 'Active' : 'Disconnected'}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Total Signals:</span>
              <span className="font-semibold text-blue-600">{stats.totalSignals}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Active Signals:</span>
              <span className="font-semibold text-green-600">{stats.activeSignals}</span>
            </div>
          </StatusCard>

          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4 text-gray-800">Performance</h2>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-gray-600">Success Rate:</span>
                <span className="text-2xl font-bold text-green-600">{stats.successRate}%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Completed:</span>
                <span className="font-semibold">{stats.completedSignals}</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div
                  className="bg-green-500 h-2 rounded-full transition-all"
                  style={{ width: `${stats.successRate}%` }}
                ></div>
              </div>
            </div>
          </div>

          <ConfigPanel title="MT4/MT5 Settings">
            <ConfigItem label="Platform" value="MT4 & MT5" status="success" />
            <ConfigItem label="Auto Trading" value="Enabled" status="success" />
            <ConfigItem label="Risk Level" value="Medium" />
          </ConfigPanel>
        </div>

        <div className="mb-6">
          <h2 className="text-2xl font-semibold mb-4 text-gray-800">📈 Active Signals</h2>
          <div className="grid lg:grid-cols-2 gap-4">
            {signals.length > 0 ? (
              signals.map((signal) => (
                <SignalCard key={signal.id} signal={signal} />
              ))
            ) : (
              <div className="col-span-2 bg-white rounded-lg shadow-md p-8 text-center">
                <p className="text-gray-500 text-lg">No signals available</p>
                <p className="text-sm text-gray-400 mt-2">
                  Signals will appear here when the AI generates new trading opportunities
                </p>
              </div>
            )}
          </div>
        </div>

        <div className="grid lg:grid-cols-2 gap-6">
          <ConfigPanel title="Expert Advisor Configuration">
            <ConfigItem label="EA Name" value="GenX Gold Master" />
            <ConfigItem label="Lot Size" value="0.01" />
            <ConfigItem label="Max Spread" value="30 pips" />
            <ConfigItem label="Magic Number" value="123456" />
            <ConfigItem label="Trailing Stop" value="Enabled" />
          </ConfigPanel>

          <ConfigPanel title="Connection Details">
            <ConfigItem label="REST API" value="http://localhost:8000/api/signals" status="success" />
            <ConfigItem label="WebSocket" value="ws://localhost:8000/ws" status="success" />
            <ConfigItem label="Poll Interval" value="5 seconds" />
            <ConfigItem label="Timeout" value="30 seconds" />
            <ConfigItem label="Retry Attempts" value="3" />
          </ConfigPanel>
        </div>

        <div className="mt-6 bg-yellow-50 border border-yellow-200 rounded-lg p-4">
          <h3 className="text-lg font-semibold text-yellow-900 mb-2">⚠️ Trading Notice</h3>
          <p className="text-sm text-yellow-800">
            Always test signals on a demo account first. Past performance does not guarantee future results. 
            Use proper risk management and never risk more than you can afford to lose.
          </p>
        </div>
      </div>
    </div>
  )
}
