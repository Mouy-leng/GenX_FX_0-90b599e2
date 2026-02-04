import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom'
import { Home } from './pages/Home'
import { AIServices } from './pages/AIServices'
import { MT45Signals } from './pages/MT45Signals'
import { PatternRecognition } from './pages/PatternRecognition'

/**
 * The main application component with routing.
 * @returns {JSX.Element} The rendered application component.
 */
function App() {
  return (
    <Router>
      <div className="min-h-screen bg-gray-50">
        <nav className="bg-white shadow-lg">
          <div className="max-w-7xl mx-auto px-4">
            <div className="flex justify-between h-16">
              <div className="flex space-x-8">
                <Link
                  to="/"
                  className="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-900 hover:border-blue-500 transition-colors"
                >
                  🏠 Home
                </Link>
                <Link
                  to="/ai-services"
                  className="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-900 hover:border-blue-500 transition-colors"
                >
                  🤖 AI Services
                </Link>
                <Link
                  to="/signals"
                  className="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-900 hover:border-blue-500 transition-colors"
                >
                  📡 MT4/MT5 Signals
                </Link>
                <Link
                  to="/patterns"
                  className="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-900 hover:border-blue-500 transition-colors"
                >
                  🔍 Pattern Recognition
                </Link>
              </div>
            </div>
          </div>
        </nav>

        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/ai-services" element={<AIServices />} />
          <Route path="/signals" element={<MT45Signals />} />
          <Route path="/patterns" element={<PatternRecognition />} />
        </Routes>
      </div>
    </Router>
  )
}

export default App
