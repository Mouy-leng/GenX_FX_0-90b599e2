# GenX FX Trading Platform - Complete Setup Guide

This guide provides comprehensive instructions for setting up the GenX FX Trading Platform from scratch.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Environment Configuration](#environment-configuration)
- [Testing Your Setup](#testing-your-setup)
- [Docker Deployment](#docker-deployment)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

- **Python 3.11+** (Tested with 3.11, 3.12, 3.13)
- **Node.js 18+** (Tested with v20.19.6)
- **npm 10+** (Tested with 10.8.2)
- **Git** (for version control)
- **Docker** (optional, for containerized deployment)

### System Requirements

- **RAM**: Minimum 4GB, recommended 8GB+
- **Storage**: 5GB free space
- **OS**: Linux, macOS, or Windows with WSL2

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Mouy-leng/GenX_FX_0.git
cd GenX_FX_0
```

### 2. Install Python Dependencies

```bash
# Upgrade pip
python -m pip install --upgrade pip

# Install requirements
pip install -r requirements.txt
```

### 3. Install Node.js Dependencies

```bash
npm install
```

### 4. Create Environment File

```bash
cp .env.example .env
```

Edit `.env` and add your API keys (see [Environment Configuration](#environment-configuration)).

### 5. Run Tests

```bash
# Python tests
python -m pytest tests/test_basic.py -v

# Node tests
npm test
```

### 6. Start Development Server

```bash
# Start all services (frontend + backend)
npm run dev
```

The application will be available at:
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8000
- **Node Server**: http://localhost:3000

## Detailed Setup

### Step 1: Python Environment Setup

#### Option A: Using Virtual Environment (Recommended)

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/macOS:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

#### Option B: System-wide Installation

```bash
python -m pip install --upgrade pip
pip install -r requirements.txt
```

### Step 2: Node.js Dependencies

```bash
# Install all Node.js packages
npm install

# If you encounter peer dependency conflicts, use:
npm install --legacy-peer-deps
```

### Step 3: Database Setup (Optional)

If using PostgreSQL:

```bash
# Run migrations
npm run db:migrate

# Open database studio
npm run db:studio
```

### Step 4: Build Frontend

```bash
# Development build
npm run build

# Preview production build
npm run preview
```

## Environment Configuration

### Required Environment Variables

Create a `.env` file in the root directory with the following variables:

```bash
# Core Application
SECRET_KEY=your_secret_key_here
LOG_LEVEL=INFO
NODE_ENV=development

# API Service
PORT=8000

# Database URLs (if using)
DATABASE_URL=postgresql://user:password@localhost:5432/genx_trading
MONGODB_URL=mongodb://localhost:27017/genx_trading
REDIS_URL=redis://localhost:6379

# Broker APIs
BYBIT_API_KEY=your_bybit_key
BYBIT_API_SECRET=your_bybit_secret
FXCM_API_TOKEN=your_fxcm_token
FXCM_URL=https://api-fxpractice.fxcm.com

# Messaging Bots
DISCORD_TOKEN=your_discord_token
TELEGRAM_TOKEN=your_telegram_token

# AI/ML Services
GEMINI_API_KEY=your_gemini_key
OPENAI_API_KEY=your_openai_key

# Data APIs
ALPHA_VANTAGE_API_KEY=your_alpha_vantage_key
NEWS_API_KEY=your_news_api_key
```

### Getting API Keys

1. **Gemini API**: https://ai.google.dev/
2. **OpenAI API**: https://platform.openai.com/api-keys
3. **Bybit API**: https://www.bybit.com/app/user/api-management
4. **FXCM API**: https://www.fxcm.com/markets/insights/forex-trading-api/
5. **Alpha Vantage**: https://www.alphavantage.co/support/#api-key
6. **News API**: https://newsapi.org/register

See [docs/API_KEY_SETUP.md](docs/API_KEY_SETUP.md) for detailed instructions.

## Testing Your Setup

### Python Tests

```bash
# Run all tests
python -m pytest tests/ -v

# Run specific test file
python -m pytest tests/test_basic.py -v

# Run with coverage
python -m pytest tests/ -v --cov=. --cov-report=html
```

### Node.js Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm test -- --watch
```

### Linting

```bash
# Python linting
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics

# JavaScript/TypeScript linting
npm run lint
```

## Docker Deployment

### Build Docker Image

```bash
docker build -t genx-fx:latest .
```

### Run with Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Production Deployment

```bash
# Use production Docker Compose
docker-compose -f docker-compose.production.yml up -d
```

## Project Structure

```
GenX_FX_0/
├── api/                  # FastAPI backend
├── ai_models/            # ML models and predictors
├── client/               # React frontend
├── core/                 # Core trading logic
│   ├── strategies/       # Trading strategies
│   ├── indicators/       # Technical indicators
│   ├── patterns/         # Pattern detection
│   └── risk_management/  # Risk management
├── services/             # External service integrations
├── expert-advisors/      # MetaTrader EAs
├── tests/                # Test files
├── docs/                 # Documentation
├── scripts/              # Utility scripts
└── deploy/               # Deployment scripts
```

## Available Scripts

### Development

```bash
npm run dev          # Start dev server (all services)
npm run client       # Start only frontend
npm run server       # Start only Node server
npm run python:dev   # Start only Python API
```

### Building

```bash
npm run build        # Build for production
npm run preview      # Preview production build
```

### Database

```bash
npm run db:generate  # Generate database schema
npm run db:migrate   # Run migrations
npm run db:studio    # Open database studio
```

### Testing

```bash
npm test            # Run Node tests
python -m pytest    # Run Python tests
```

## Troubleshooting

### Common Issues

#### 1. Python Dependencies Fail to Install

**Issue**: `ta-lib` fails to compile

**Solution**:
```bash
# Ubuntu/Debian
sudo apt-get install ta-lib

# macOS
brew install ta-lib

# Windows: Download from https://www.lfd.uci.edu/~gohlke/pythonlibs/#ta-lib
```

#### 2. Node Peer Dependency Conflicts

**Issue**: npm install fails with peer dependency errors

**Solution**:
```bash
npm install --legacy-peer-deps
```

#### 3. Port Already in Use

**Issue**: Port 8000 or 5173 already in use

**Solution**:
```bash
# Find process using the port (Linux/macOS)
lsof -ti:8000 | xargs kill -9

# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

#### 4. Permission Denied on Scripts

**Solution**:
```bash
chmod +x *.sh
```

#### 5. Module Not Found Errors

**Solution**:
```bash
# Reinstall Python dependencies
pip install --upgrade --force-reinstall -r requirements.txt

# Reinstall Node dependencies
rm -rf node_modules package-lock.json
npm install
```

### Getting Help

- **Documentation**: See [docs/](docs/) directory
- **Issues**: https://github.com/Mouy-leng/GenX_FX_0/issues
- **Security**: See [SECURITY.md](SECURITY.md)

## Next Steps

After completing the setup:

1. **For Traders**: See [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md)
2. **For Developers**: See [docs/SYSTEM_ARCHITECTURE_GUIDE.md](docs/SYSTEM_ARCHITECTURE_GUIDE.md)
3. **For Deployment**: See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)
4. **For MT4/5 Integration**: See [docs/EA_SETUP_GUIDE.md](docs/EA_SETUP_GUIDE.md)

## CI/CD Integration

This project includes GitHub Actions workflows for:

- **Continuous Integration**: Automated testing on push/PR
- **Security Scanning**: Trivy vulnerability scanning
- **Code Quality**: Linting and formatting checks
- **Docker Build**: Automated Docker image building
- **Deployment**: Automated deployment to staging/production

See [.github/workflows/](.github/workflows/) for workflow configurations.

## Contributing

See [CODE_OF_CONDUCT.md](docs/CODE_OF_CONDUCT.md) for contribution guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Status**: ✅ Setup Complete
**Last Updated**: 2026-01-03
**Version**: 0.0.0
