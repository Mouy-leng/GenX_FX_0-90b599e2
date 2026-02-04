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

interface SignalCardProps {
  signal: Signal
}

export function SignalCard({ signal }: SignalCardProps) {
  const statusColors = {
    active: 'bg-blue-100 text-blue-800',
    completed: 'bg-green-100 text-green-800',
    cancelled: 'bg-red-100 text-red-800',
  }

  const confidenceColor = (confidence: number) => {
    if (confidence >= 80) return 'text-green-600'
    if (confidence >= 60) return 'text-yellow-600'
    return 'text-red-600'
  }

  return (
    <div className="bg-white rounded-lg shadow-md p-4 border-l-4 border-blue-500">
      <div className="flex justify-between items-start mb-3">
        <div>
          <h3 className="text-lg font-bold text-gray-900">{signal.symbol}</h3>
          <span className={`inline-block px-2 py-1 rounded text-xs font-semibold ${statusColors[signal.status]}`}>
            {signal.status.toUpperCase()}
          </span>
        </div>
        <div className="text-right">
          <p className="text-xs text-gray-500">Confidence</p>
          <p className={`text-lg font-bold ${confidenceColor(signal.confidence)}`}>
            {signal.confidence}%
          </p>
        </div>
      </div>
      
      <div className="grid grid-cols-3 gap-3 text-sm">
        <div>
          <p className="text-gray-500">Entry</p>
          <p className="font-semibold text-gray-900">{signal.entry.toFixed(2)}</p>
        </div>
        <div>
          <p className="text-gray-500">Target</p>
          <p className="font-semibold text-green-600">{signal.target.toFixed(2)}</p>
        </div>
        <div>
          <p className="text-gray-500">Stop Loss</p>
          <p className="font-semibold text-red-600">{signal.stopLoss.toFixed(2)}</p>
        </div>
      </div>
      
      {signal.timestamp && (
        <p className="text-xs text-gray-400 mt-3">
          {new Date(signal.timestamp).toLocaleString()}
        </p>
      )}
    </div>
  )
}
