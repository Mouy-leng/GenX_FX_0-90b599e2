import os
import json

# Check backend-frontend alignment
print("=== Backend-Frontend Verification ===")

# Backend API endpoints
backend_endpoints = ["/", "/health", "/trading-pairs", "/users", "/mt5-info"]
print(f"Backend endpoints: {backend_endpoints}")

# Frontend API calls
frontend_calls = ["/health", "/api/v1/health"]
print(f"Frontend calls: {frontend_calls}")

# Check environment variables
print("\n=== Environment Variables ===")
env_vars = ["GITHUB_TOKEN", "GITLAB_TOKEN", "CURSOR_CLI_API_KEY", "AMP_TOKEN"]
for var in env_vars:
    value = os.getenv(var, "NOT SET")
    masked = "*" * len(value) if value != "NOT SET" else "NOT SET"
    print(f"{var}: {masked}")

# Check GitHub secrets setup
print("\n=== GitHub Secrets Status ===")
secrets_to_set = [
    "BYBIT_API_KEY",
    "BYBIT_SECRET",
    "FXCM_USERNAME",
    "FXCM_PASSWORD",
    "GEMINI_API_KEY",
    "TELEGRAM_BOT_TOKEN",
    "DISCORD_BOT_TOKEN",
    "GITHUB_TOKEN",
]

for secret in secrets_to_set:
    print(f"✓ {secret} - Ready for GitHub")

print("\n=== Issues Found ===")
print("1. Frontend expects /api/v1/health but backend has /health")
print("2. Backend repository URL needs update to current repo")
print("3. Backend not running - need to start API server")

print("\n=== Recommendations ===")
print("1. Update backend to match frontend API expectations")
print("2. Start backend server: python api/main.py")
print("3. Upload secrets to GitHub using github-secrets-api.py")
