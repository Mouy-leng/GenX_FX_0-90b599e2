import { ReactNode } from 'react'

interface StatusCardProps {
  title: string
  status: 'healthy' | 'unhealthy' | 'unknown'
  children: ReactNode
  icon?: ReactNode
}

export function StatusCard({ title, status, children, icon }: StatusCardProps) {
  const statusColors = {
    healthy: 'bg-green-500',
    unhealthy: 'bg-red-500',
    unknown: 'bg-gray-500',
  }

  const statusText = {
    healthy: 'Healthy',
    unhealthy: 'Unhealthy',
    unknown: 'Unknown',
  }

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          {icon}
          <h2 className="text-2xl font-semibold text-gray-800">{title}</h2>
        </div>
        <div className="flex items-center gap-2">
          <span className={`w-3 h-3 rounded-full ${statusColors[status]}`}></span>
          <span className="text-sm font-medium">{statusText[status]}</span>
        </div>
      </div>
      <div className="space-y-2">{children}</div>
    </div>
  )
}
