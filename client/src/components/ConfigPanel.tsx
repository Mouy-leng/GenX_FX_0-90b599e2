import { ReactNode } from 'react'

interface ConfigPanelProps {
  title: string
  children: ReactNode
}

export function ConfigPanel({ title, children }: ConfigPanelProps) {
  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h3 className="text-xl font-semibold mb-4 text-gray-800">{title}</h3>
      <div className="space-y-3">{children}</div>
    </div>
  )
}

interface ConfigItemProps {
  label: string
  value: string | number
  status?: 'success' | 'warning' | 'error'
}

export function ConfigItem({ label, value, status }: ConfigItemProps) {
  const statusColors = {
    success: 'text-green-600',
    warning: 'text-yellow-600',
    error: 'text-red-600',
  }

  return (
    <div className="flex justify-between items-center py-2 border-b border-gray-100">
      <span className="text-sm text-gray-600">{label}</span>
      <span className={`text-sm font-medium ${status ? statusColors[status] : 'text-gray-900'}`}>
        {value}
      </span>
    </div>
  )
}
