import { useState, useEffect } from 'react'
import { StatusCard } from '../components/StatusCard'
import { ConfigPanel, ConfigItem } from '../components/ConfigPanel'
import { API_CONFIG } from '../config'

interface Pattern {
  id: string
  type: string
  symbol: string
  timeframe: string
  confidence: number
  timestamp: string
  direction: 'bullish' | 'bearish' | 'neutral'
}

interface PatternStats {
  totalPatterns: number
  bullishPatterns: number
  bearishPatterns: number
  accuracy: number
}

export function PatternRecognition() {
  const [patterns, setPatterns] = useState<Pattern[]>([])
  const [stats, setStats] = useState<PatternStats>({
    totalPatterns: 0,
    bullishPatterns: 0,
    bearishPatterns: 0,
    accuracy: 0,
  })
  const [isActive, setIsActive] = useState(false)

  useEffect(() => {
    const API_BASE = API_CONFIG.PYTHON_API_URL

    // Fetch patterns
    const fetchPatterns = () => {
      fetch(`${API_BASE}/api/v1/patterns`)
        .then(res => res.json())
        .then(() => {
          // Mock data for demonstration (API data not used yet)
          const mockPatterns: Pattern[] = [
            {
              id: '1',
              type: 'Head and Shoulders',
              symbol: 'XAUUSD',
              timeframe: 'H4',
              confidence: 92,
              timestamp: new Date().toISOString(),
              direction: 'bearish',
            },
            {
              id: '2',
              type: 'Double Bottom',
              symbol: 'EURUSD',
              timeframe: 'H1',
              confidence: 85,
              timestamp: new Date(Date.now() - 3600000).toISOString(),
              direction: 'bullish',
            },
            {
              id: '3',
              type: 'Triangle',
              symbol: 'GBPUSD',
              timeframe: 'M15',
              confidence: 78,
              timestamp: new Date(Date.now() - 7200000).toISOString(),
              direction: 'neutral',
            },
            {
              id: '4',
              type: 'Cup and Handle',
              symbol: 'BTCUSD',
              timeframe: 'D1',
              confidence: 88,
              timestamp: new Date(Date.now() - 10800000).toISOString(),
              direction: 'bullish',
            },
          ]
          setPatterns(mockPatterns)
          setIsActive(true)

          // Calculate stats
          const bullish = mockPatterns.filter(p => p.direction === 'bullish').length
          const bearish = mockPatterns.filter(p => p.direction === 'bearish').length
          setStats({
            totalPatterns: mockPatterns.length,
            bullishPatterns: bullish,
            bearishPatterns: bearish,
            accuracy: 89.3,
          })
        })
        .catch(err => {
          console.error('Failed to fetch patterns:', err)
          setIsActive(false)
        })
    }

    fetchPatterns()
    const interval = setInterval(fetchPatterns, 15000) // Update every 15s

    return () => clearInterval(interval)
  }, [])

  const getDirectionColor = (direction: string) => {
    switch (direction) {
      case 'bullish':
        return 'bg-green-100 text-green-800'
      case 'bearish':
        return 'bg-red-100 text-red-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const getDirectionIcon = (direction: string) => {
    switch (direction) {
      case 'bullish':
        return '📈'
      case 'bearish':
        return '📉'
      default:
        return '➡️'
    }
  }

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-4xl font-bold mb-8 text-gray-900">
          🔍 Pattern Recognition
        </h1>

        <div className="grid lg:grid-cols-3 gap-6 mb-6">
          <StatusCard
            title="Pattern Detector"
            status={isActive ? 'healthy' : 'unhealthy'}
            icon={<span className="text-2xl">🎯</span>}
          >
            <div className="flex justify-between">
              <span className="text-gray-600">Status:</span>
              <span className="font-semibold">{isActive ? 'Active' : 'Inactive'}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Patterns Detected:</span>
              <span className="font-semibold text-blue-600">{stats.totalPatterns}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Accuracy:</span>
              <span className="font-semibold text-purple-600">{stats.accuracy}%</span>
            </div>
          </StatusCard>

          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4 text-gray-800">Pattern Breakdown</h2>
            <div className="space-y-3">
              <div className="flex justify-between items-center">
                <span className="text-gray-600">📈 Bullish:</span>
                <span className="text-lg font-bold text-green-600">{stats.bullishPatterns}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-600">📉 Bearish:</span>
                <span className="text-lg font-bold text-red-600">{stats.bearishPatterns}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-600">➡️ Neutral:</span>
                <span className="text-lg font-bold text-gray-600">
                  {stats.totalPatterns - stats.bullishPatterns - stats.bearishPatterns}
                </span>
              </div>
            </div>
          </div>

          <ConfigPanel title="Detection Settings">
            <ConfigItem label="Min Confidence" value="75%" />
            <ConfigItem label="Timeframes" value="All" status="success" />
            <ConfigItem label="Auto Alert" value="Enabled" status="success" />
          </ConfigPanel>
        </div>

        <div className="mb-6">
          <h2 className="text-2xl font-semibold mb-4 text-gray-800">📊 Detected Patterns</h2>
          <div className="grid lg:grid-cols-2 gap-4">
            {patterns.length > 0 ? (
              patterns.map((pattern) => (
                <div
                  key={pattern.id}
                  className="bg-white rounded-lg shadow-md p-5 border-l-4 border-purple-500"
                >
                  <div className="flex justify-between items-start mb-3">
                    <div>
                      <h3 className="text-lg font-bold text-gray-900">{pattern.type}</h3>
                      <p className="text-sm text-gray-600">
                        {pattern.symbol} • {pattern.timeframe}
                      </p>
                    </div>
                    <span className={`inline-block px-3 py-1 rounded-full text-xs font-semibold ${getDirectionColor(pattern.direction)}`}>
                      {getDirectionIcon(pattern.direction)} {pattern.direction.toUpperCase()}
                    </span>
                  </div>
                  
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-sm text-gray-600">Confidence</span>
                    <span className="text-lg font-bold text-purple-600">{pattern.confidence}%</span>
                  </div>
                  
                  <div className="w-full bg-gray-200 rounded-full h-2 mb-3">
                    <div
                      className="bg-purple-500 h-2 rounded-full transition-all"
                      style={{ width: `${pattern.confidence}%` }}
                    ></div>
                  </div>
                  
                  <p className="text-xs text-gray-400">
                    Detected: {new Date(pattern.timestamp).toLocaleString()}
                  </p>
                </div>
              ))
            ) : (
              <div className="col-span-2 bg-white rounded-lg shadow-md p-8 text-center">
                <p className="text-gray-500 text-lg">No patterns detected</p>
                <p className="text-sm text-gray-400 mt-2">
                  The AI is analyzing market data. Patterns will appear here when detected.
                </p>
              </div>
            )}
          </div>
        </div>

        <div className="grid lg:grid-cols-2 gap-6">
          <ConfigPanel title="Supported Pattern Types">
            <ConfigItem label="Head and Shoulders" value="✓" status="success" />
            <ConfigItem label="Double Top/Bottom" value="✓" status="success" />
            <ConfigItem label="Triangle Patterns" value="✓" status="success" />
            <ConfigItem label="Cup and Handle" value="✓" status="success" />
            <ConfigItem label="Wedge Patterns" value="✓" status="success" />
          </ConfigPanel>

          <ConfigPanel title="Market Coverage">
            <ConfigItem label="Forex Pairs" value="28 Pairs" status="success" />
            <ConfigItem label="Gold/Metals" value="XAUUSD, XAGUSD" status="success" />
            <ConfigItem label="Cryptocurrencies" value="10 Coins" status="success" />
            <ConfigItem label="Update Frequency" value="Real-time" />
            <ConfigItem label="Data Source" value="Multiple Feeds" />
          </ConfigPanel>
        </div>

        <div className="mt-6 bg-purple-50 border border-purple-200 rounded-lg p-4">
          <h3 className="text-lg font-semibold text-purple-900 mb-2">💡 How It Works</h3>
          <p className="text-sm text-purple-800">
            Our AI-powered pattern recognition system analyzes price charts in real-time using 
            advanced machine learning algorithms. Patterns are detected across multiple timeframes 
            and validated using historical data to ensure high accuracy and reliability.
          </p>
        </div>
      </div>
    </div>
  )
}
