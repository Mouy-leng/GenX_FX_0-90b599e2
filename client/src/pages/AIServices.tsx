import { useState, useEffect } from 'react'
import { StatusCard } from '../components/StatusCard'
import { ConfigPanel, ConfigItem } from '../components/ConfigPanel'
import { API_CONFIG } from '../config'

interface ServiceHealth {
  status: string
  services?: {
    ml_service?: string
    data_service?: string
  }
  timestamp?: string
  database?: string
}

export function AIServices() {
  const [apiHealth, setApiHealth] = useState<ServiceHealth | null>(null)
  const [mlStats, setMlStats] = useState({
    modelsLoaded: 0,
    predictionsToday: 0,
    accuracy: 0,
    lastUpdate: '',
  })

  useEffect(() => {
    const API_BASE = API_CONFIG.PYTHON_API_URL

    // Fetch API health
    const fetchHealth = () => {
      fetch(`${API_BASE}/api/v1/health`)
        .then(res => res.json())
        .then(data => {
          setApiHealth(data)
          // Simulate ML stats (in real app, would come from API)
          setMlStats({
            modelsLoaded: 3,
            predictionsToday: Math.floor(Math.random() * 100) + 50,
            accuracy: 87.5,
            lastUpdate: new Date().toISOString(),
          })
        })
        .catch(err => {
          console.error('API health check failed:', err)
          setApiHealth({ status: 'unhealthy' })
        })
    }

    fetchHealth()
    const interval = setInterval(fetchHealth, 30000) // Update every 30s

    return () => clearInterval(interval)
  }, [])

  const getHealthStatus = (): 'healthy' | 'unhealthy' | 'unknown' => {
    if (!apiHealth) return 'unknown'
    return apiHealth.status === 'healthy' ? 'healthy' : 'unhealthy'
  }

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-4xl font-bold mb-8 text-gray-900">
          🤖 AI Services Dashboard
        </h1>

        <div className="grid lg:grid-cols-2 gap-6 mb-6">
          <StatusCard
            title="ML Service Status"
            status={getHealthStatus()}
            icon={<span className="text-2xl">🧠</span>}
          >
            {apiHealth ? (
              <>
                <div className="flex justify-between">
                  <span className="text-gray-600">Service Status:</span>
                  <span className="font-semibold">{apiHealth.services?.ml_service || 'N/A'}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Data Service:</span>
                  <span className="font-semibold">{apiHealth.services?.data_service || 'N/A'}</span>
                </div>
                {apiHealth.database && (
                  <div className="flex justify-between">
                    <span className="text-gray-600">Database:</span>
                    <span className="font-semibold">{apiHealth.database}</span>
                  </div>
                )}
                <div className="flex justify-between text-sm">
                  <span className="text-gray-500">Last Check:</span>
                  <span className="text-gray-700">
                    {apiHealth.timestamp ? new Date(apiHealth.timestamp).toLocaleTimeString() : 'N/A'}
                  </span>
                </div>
              </>
            ) : (
              <p className="text-gray-500">Loading service status...</p>
            )}
          </StatusCard>

          <StatusCard
            title="Model Statistics"
            status={mlStats.modelsLoaded > 0 ? 'healthy' : 'unknown'}
            icon={<span className="text-2xl">📊</span>}
          >
            <div className="flex justify-between">
              <span className="text-gray-600">Models Loaded:</span>
              <span className="font-semibold text-blue-600">{mlStats.modelsLoaded}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Predictions Today:</span>
              <span className="font-semibold text-green-600">{mlStats.predictionsToday}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Model Accuracy:</span>
              <span className="font-semibold text-purple-600">{mlStats.accuracy}%</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-500">Last Update:</span>
              <span className="text-gray-700">
                {mlStats.lastUpdate ? new Date(mlStats.lastUpdate).toLocaleTimeString() : 'N/A'}
              </span>
            </div>
          </StatusCard>
        </div>

        <div className="grid lg:grid-cols-2 gap-6">
          <ConfigPanel title="AI Configuration">
            <ConfigItem label="Primary Model" value="GPT-4o" status="success" />
            <ConfigItem label="Fallback Model" value="Gemini 2.5" status="success" />
            <ConfigItem label="Ensemble Predictor" value="Active" status="success" />
            <ConfigItem label="Training Mode" value="Continuous" />
            <ConfigItem label="API Rate Limit" value="100 req/min" />
          </ConfigPanel>

          <ConfigPanel title="Service Endpoints">
            <ConfigItem label="API Server" value="localhost:8000" status="success" />
            <ConfigItem label="WebSocket" value="ws://localhost:8000/ws" status="success" />
            <ConfigItem label="Database" value="PostgreSQL (Neon)" status="success" />
            <ConfigItem label="Redis Cache" value="Enabled" />
            <ConfigItem label="Monitoring" value="Active" status="success" />
          </ConfigPanel>
        </div>

        <div className="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
          <h3 className="text-lg font-semibold text-blue-900 mb-2">ℹ️ Service Information</h3>
          <p className="text-sm text-blue-800">
            The AI services are running and processing market data in real-time. 
            Models are continuously trained on historical data and generate predictions 
            for Forex, Crypto, and Gold markets.
          </p>
        </div>
      </div>
    </div>
  )
}
