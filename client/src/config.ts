// API configuration
export const API_CONFIG = {
  // Node.js server (proxies to Python API)
  NODE_API_URL: import.meta.env.VITE_NODE_API_URL || 'http://localhost:8081',
  // Python FastAPI backend
  PYTHON_API_URL: import.meta.env.VITE_PYTHON_API_URL || 'http://localhost:8000',
}
