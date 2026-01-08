import { useState, useEffect } from 'react'
import SystemTestResults from './components/SystemTestResults'

/**
 * The main application component.
 * It fetches and displays the health status of the Node.js server and the Python API.
 * @returns {JSX.Element} The rendered application component.
 */
function App() {
  const [health, setHealth] = useState<any>(null)
  const [apiHealth, setApiHealth] = useState<any>(null)

  useEffect(() => {
    const API = 'http://localhost:8081';

    /**
     * Optimization: Parallel API Calls
     *
     * The health checks for the Node.js server and Python API are independent.
     * By using Promise.all, we can run them in parallel instead of sequentially.
     * This reduces the total time to fetch data, making the UI load faster.
     *
     * Estimated impact: Reduces load time by up to 50% (depending on network latency).
     */
    const fetchHealthData = async () => {
      const results = await Promise.allSettled([
        fetch(`${API}/health`),
        fetch(`${API}/api/v1/health`)
      ]);

      // Handle Node.js server health response
      if (results[0].status === 'fulfilled') {
        const healthData = await results[0].value.json();
        setHealth(healthData);
      } else {
        console.error('Node.js server error:', results[0].reason);
      }

      // Handle Python API health response
      if (results[1].status === 'fulfilled') {
        const apiHealthData = await results[1].value.json();
        setApiHealth(apiHealthData);
      } else {
        console.error('Python API error:', results[1].reason);
      }
    };

    fetchHealthData();
  }, []);

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold text-center mb-8 text-gray-900">
          🚀 GenX FX Trading Platform
        </h1>
        
        <div className="grid md:grid-cols-2 gap-6">
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-2xl font-semibold mb-4 text-gray-800">
              Node.js Server Status
            </h2>
            {health ? (
              <div className="space-y-2">
                <div className="flex items-center">
                  <span className="w-3 h-3 bg-green-500 rounded-full mr-2"></span>
                  <span>Status: {health.status}</span>
                </div>
                <div>Environment: {health.environment}</div>
                <div>Timestamp: {health.timestamp}</div>
              </div>
            ) : (
              <div className="flex items-center">
                <span className="w-3 h-3 bg-red-500 rounded-full mr-2"></span>
                <span>Server not responding</span>
              </div>
            )}
          </div>

          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-2xl font-semibold mb-4 text-gray-800">
              Python API Status
            </h2>
            {apiHealth ? (
              <div className="space-y-2">
                <div className="flex items-center">
                  <span className="w-3 h-3 bg-green-500 rounded-full mr-2"></span>
                  <span>Status: {apiHealth.status}</span>
                </div>
                <div>ML Service: {apiHealth.services?.ml_service}</div>
                <div>Data Service: {apiHealth.services?.data_service}</div>
                <div>Timestamp: {apiHealth.timestamp}</div>
              </div>
            ) : (
              <div className="flex items-center">
                <span className="w-3 h-3 bg-red-500 rounded-full mr-2"></span>
                <span>API not responding</span>
              </div>
            )}
          </div>
        </div>

        <SystemTestResults />
      </div>
    </div>
  )
}

export default App
